resource "aws_cloudwatch_log_group" "alloy" {
  name = "/ecs/alloy"
  retention_in_days = 1
}