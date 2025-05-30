data "aws_secretsmanager_secret" "grafana_cloud_loki_instance_id" {
  name = "grafana-cloud-hosted-logs-id"
}

data "aws_secretsmanager_secret" "grafana_cloud_loki_write_token" {
  name = "grafana-cloud-api-key"
}
