resource "aws_ssm_parameter" "alloy_config" {
  name = "ALLOY_CONFIG"
  type = "String"
  value = filebase64("config/config.alloy")
}