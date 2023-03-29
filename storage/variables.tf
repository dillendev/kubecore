variable "longhorn" {
  type = object({
    chart_version = string
    hostname      = optional(string, "longhorn-dashboard")
    ingress_class = optional(string, "nginx")
    replica_count = optional(number, 3)
    dashboard = optional(object({
      enabled = bool
      }), {
      enabled = false
    })
  })
}

variable "backup" {
  type = object({
    enabled = bool
    s3 = optional(object({
      region = string
      bucket = string
    }))
  })
}

variable "monitoring" {
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "cluster_issuer" {
  type    = string
  default = "letsencrypt-prod"
}
