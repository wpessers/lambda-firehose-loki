variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "default_vpc_id" {
  type    = string
  default = "vpc-074afc85a771ded15"
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
