resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx.chart_version
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.config.use-gzip"
    value = "true"
  }

  set {
    name  = "controller.config.enable-brotli"
    value = "true"
  }

  set {
    name  = "controller.config.proxy-buffering"
    value = "on"
  }

  set {
    name  = "controller.config.ssl-early-data"
    value = "true"
  }

  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }

  set {
    name  = "controller.config.client-body-buffer-size"
    value = "10m"
  }

  set {
    name  = "controller.autoscaling.enabled"
    value = "false"
  }

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.replicaCount"
    value = "3"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = false
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}
