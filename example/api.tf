resource "aws_apigatewayv2_api" "example" {
  name          = var.http_api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "example-dev" {
  api_id = aws_apigatewayv2_api.example.id
  name   = "example-dev"
}

resource "aws_apigatewayv2_api_mapping" "example-dev" {
  api_id      = aws_apigatewayv2_api.example.id
  domain_name = aws_apigatewayv2_domain_name.example.id
  stage       = aws_apigatewayv2_stage.example-dev.id
}