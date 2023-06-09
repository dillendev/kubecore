resource "helm_release" "metrics-server" {
  count            = var.metrics.enabled ? 1 : 0
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.metrics.chart_version
  namespace        = "metrics-server"
  create_namespace = true
}
