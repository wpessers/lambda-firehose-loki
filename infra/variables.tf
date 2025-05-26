variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "grafana_cloud_loki_endpoint" {
  type = string
}

variable "grafana_cloud_loki_instance_id" {
  type = string
}

variable "grafana_cloud_loki_token" {
  type = string
}
