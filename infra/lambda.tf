locals {
  lambda_function_name = "hello-world"
}

resource "aws_lambda_function" "hello_world" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.hello_world_lambda.arn

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
    log_group  = aws_cloudwatch_log_group.export.name
  }
}

resource "aws_cloudwatch_log_group" "export" {
  name            = "/aws/lambda/${local.lambda_function_name}"
  log_group_class = "DELIVERY"
}

data "aws_iam_policy_document" "logs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "logs_log_export" {
  name               = "${local.lambda_function_name}-lambda-log-export-role"
  assume_role_policy = data.aws_iam_policy_document.logs_assume_role.json
}

data "aws_iam_policy_document" "log_export_kinesis" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
      "firehose:ListTagsForDeliveryStream"
    ]
    effect    = "Allow"
    resources = ["${aws_kinesis_firehose_delivery_stream.logs_stream.arn}"]
  }
}

resource "aws_iam_role_policy" "lambda_log_export" {
  role   = aws_iam_role.logs_log_export.name
  policy = data.aws_iam_policy_document.log_export_kinesis.json
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_log_export" {
  name            = "${local.lambda_function_name}-filter"
  log_group_name  = aws_cloudwatch_log_group.export.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_stream.arn
  role_arn        = aws_iam_role.logs_log_export.arn
}


data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hello_world_lambda" {
  name               = "${local.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

data "aws_iam_policy" "lambda_basic" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachments_exclusive" "hello_world_lambda" {
  policy_arns = [
    data.aws_iam_policy.lambda_basic.arn
  ]
  role_name = aws_iam_role.hello_world_lambda.name
}

resource "aws_lambda_permission" "apigw_invoke_hello_world_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world.execution_arn}/*"
}
