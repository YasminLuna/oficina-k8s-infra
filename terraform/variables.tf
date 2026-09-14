variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "hml"
}

variable "cluster_name" {
  type    = string
  default = "oficina"
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
  default   = ""
}
