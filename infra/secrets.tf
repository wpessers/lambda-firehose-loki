data "aws_secretsmanager_secret" "grafana_cloud_api_key" {
  name = "grafana-cloud-api-key"
}

data "aws_secretsmanager_secret" "grafana_cloud_fleet_manager_id" {
  name = "grafana-cloud-fleet-manager-id"
}

data "aws_secretsmanager_secret" "grafana_cloud_hosted_logs_id" {
  name = "grafana-cloud-hosted-logs-id"
}

data "aws_secretsmanager_secret" "grafana_cloud_hosted_metrics_id" {
  name = "grafana-cloud-hosted-metrics-id"
}
