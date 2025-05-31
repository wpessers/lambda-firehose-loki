data "aws_secretsmanager_secret" "loki_instance_id" {
  name = "loki-instance-id"
}

data "aws_secretsmanager_secret_version" "loki_instance_id" {
  secret_id = data.aws_secretsmanager_secret.loki_instance_id.id
}

data "aws_secretsmanager_secret" "loki_write_token" {
  name = "loki-write-token"
}

data "aws_secretsmanager_secret_version" "loki_write_token" {
  secret_id = data.aws_secretsmanager_secret.loki_write_token.id
}
