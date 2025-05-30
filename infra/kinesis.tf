resource "aws_kinesis_firehose_delivery_stream" "logs_stream" {
  name        = "firehose-stream-logs-to-grafana-cloud"
  destination = "http_endpoint"

  http_endpoint_configuration {
    name       = "Grafana Alloy"
    url        = var.grafana_cloud_loki_endpoint
    access_key = format("%s:%s", data.aws_secretsmanager_secret.grafana_cloud_hosted_logs_id, data.aws_secretsmanager_secret.grafana_cloud_api_key)

    role_arn       = aws_iam_role.s3_backup.arn
    s3_backup_mode = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.s3_backup.arn
      bucket_arn         = aws_s3_bucket.firehose_backup.arn
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_backup" {
  name               = "firehose-s3-backup-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.firehose_backup.arn,
      "${aws_s3_bucket.firehose_backup.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_backup" {
  role   = aws_iam_role.s3_backup.name
  policy = data.aws_iam_policy_document.s3_policy.json
}
