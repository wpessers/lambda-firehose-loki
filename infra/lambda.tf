data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "hello-world-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world"
  role          = aws_iam_role.lambda_execution_role.arn

  filename         = "../dist/lambdas.zip"
  handler          = "lambdas/helloWorldLambda.handler"
  source_code_hash = filebase64sha256("../dist/lambdas.zip")

  runtime       = "nodejs22.x"
  architectures = ["arm64"]

  tracing_config {
    mode = "PassThrough"
  }
}


data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log_group.arn}:*"]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "hello-world-lambda-role-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
  role   = aws_iam_role.lambda_execution_role.id
}

resource "aws_lambda_permission" "apigw_invoke_hello_world_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world.execution_arn}/*"
}
