variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "grafana_cloud_loki_endpoint" {
  type    = string
  default = "https://aws-logs-prod-012.grafana.net/aws-logs/api/v1/push"
}
