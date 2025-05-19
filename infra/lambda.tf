locals {
  lambda_function_name = "hello-world"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name            = "/aws/lambda/${local.lambda_function_name}"
  log_group_class = "DELIVERY"
}

resource "aws_lambda_function" "hello_world" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn

  filename         = "../dist/lambdas.zip"
  handler          = "lambdas/helloWorldLambda.handler"
  source_code_hash = filebase64sha256("../dist/lambdas.zip")

  runtime       = "nodejs22.x"
  architectures = ["arm64"]

  tracing_config {
    mode = "PassThrough"
  }

  logging_config {
    log_format = "JSON"
    log_group  = aws_cloudwatch_log_group.log_group.arn
  }
}

resource "aws_lambda_permission" "apigw_invoke_hello_world_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world.execution_arn}/*"
}
