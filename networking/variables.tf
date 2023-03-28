variable "ingress_nginx" {
  type = object({
    chart_version = string
  })
}

variable "cert_manager" {
  type = object({
    chart_version = string
    acme = object({
      email = string
    })
  })
}
