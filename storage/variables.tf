variable "longhorn" {
  type = object({
    chart_version = string
    hostname      = string
    ingress_class = string
  })
}

variable "backup" {
  type = object({
    enabled = bool
    s3 = object({
      region = string
      bucket = string
    })
  })
}

variable "monitoring" {
  type = object({
    enabled = bool
  })
}

variable "cluster_issuer" {
  type    = string
  default = "letsencrypt-prod"
}
