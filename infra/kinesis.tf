resource "aws_kinesis_firehose_delivery_stream" "logs_stream" {
  name        = "firehose-stream-logs-to-grafana-cloud"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url = ""

    s3_configuration {
      role_arn   = ""
      bucket_arn = ""
    }
  }
}
