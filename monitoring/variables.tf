variable "metrics" {
  type = object({
    chart_version = string
    enabled       = bool
  })
  default = {
    enabled = false
  }
}
