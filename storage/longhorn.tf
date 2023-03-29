resource "kubernetes_namespace" "longhorn-system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "kubectl_manifest" "longhorn-basic-auth" {
  count      = var.longhorn.dashboard.enabled ? 1 : 0
  depends_on = [kubernetes_namespace.longhorn-system]
  yaml_body = yamlencode({
    apiVersion = "onepassword.com/v1"
    kind       = "OnePasswordItem"
    metadata = {
      name      = "longhorn-basic-auth"
      namespace = kubernetes_namespace.longhorn-system.metadata[0].name
    }
    spec = {
      itemPath = "vaults/Kubernetes/items/longhorn-basic-auth"
    }
  })
}

# TODO: abstract secret creation
resource "kubectl_manifest" "longhorn-s3-credentials" {
  count      = var.backup.enabled ? 1 : 0
  depends_on = [kubernetes_namespace.longhorn-system]
  yaml_body = yamlencode({
    apiVersion = "onepassword.com/v1"
    kind       = "OnePasswordItem"
    metadata = {
      name      = "longhorn-s3-credentials"
      namespace = kubernetes_namespace.longhorn-system.metadata[0].name
    }
    spec = {
      itemPath = "vaults/Kubernetes/items/longhorn-s3-credentials"
    }
  })
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  chart            = "longhorn"
  repository       = "https://charts.longhorn.io"
  version          = var.longhorn.chart_version
  namespace        = "longhorn-system"
  create_namespace = true
  depends_on = [
    kubectl_manifest.longhorn-basic-auth,
    kubectl_manifest.longhorn-s3-credentials,
  ]

  set {
    name  = "ingress.enabled"
    value = var.longhorn.dashboard.enabled
  }

  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = var.cluster_issuer
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-type"
    value = "basic"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-realm"
    value = "Authentication Required"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-secret"
    value = "longhorn-basic-auth"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-body-size"
    value = "1500m"
  }

  set {
    name  = "ingress.ingressClassName"
    value = var.longhorn.ingress_class
  }

  set {
    name  = "ingress.host"
    value = var.longhorn.hostname
  }

  set {
    name  = "ingress.tls"
    value = true
  }

  set {
    name  = "ingress.tlsSecret"
    value = var.longhorn.hostname
  }

  set {
    name  = "persistence.defaultClassReplicaCount"
    value = var.longhorn.replica_count
  }

  dynamic "set" {
    for_each = var.backup.enabled ? [""] : []
    content {
      name  = "defaultSettings.backupTarget"
      value = "s3://${var.backup.s3.bucket}@${var.backup.s3.region}/"
    }
  }

  dynamic "set" {
    for_each = var.backup.enabled ? [""] : []
    content {
      name  = "defaultSettings.backupTargetCredentialSecret"
      value = "longhorn-s3-credentials"
    }
  }
}

resource "kubectl_manifest" "longhorn-service-monitor" {
  count      = var.monitoring.enabled ? 1 : 0
  depends_on = [kubernetes_namespace.longhorn-system]
  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "longhorn-prometheus-servicemonitor"
      namespace = kubernetes_namespace.longhorn-system.metadata[0].name
      labels = {
        name     = "longhorn-prometheus-servicemonitor"
        instance = "primary"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "longhorn-manager"
        }
      }
      namespaceSelector = {
        matchNames = ["longhorn-system"]
      }
      endpoints = [{
        port = "manager"
        metricRelabelings = [{
          action       = "keep"
          regex        = "longhorn_volume.*|longhorn_disk.*"
          sourceLabels = ["__name__"]
        }]
      }]
    }
  })
}

