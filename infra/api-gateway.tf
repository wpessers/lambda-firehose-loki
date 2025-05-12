resource "aws_api_gateway_rest_api" "hello_world" {
  name = "hello-world-rest-api"
  body = templatefile("../src/openapi.json", {
    hello_world_lambda_arn = aws_lambda_function.hello_world.arn
  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "test" {
  depends_on = [aws_api_gateway_rest_api.hello_world]

  rest_api_id = aws_api_gateway_rest_api.hello_world.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.hello_world.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "test" {
  deployment_id = aws_api_gateway_deployment.test.id
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  stage_name    = "test"
}
