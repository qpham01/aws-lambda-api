
resource "aws_apigatewayv2_api" "blog-api" {
  name          = "blog-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "add-blog" {
  api_id             = aws_apigatewayv2_api.blog-api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = "${aws_lambda_function.add-blog.invoke_arn}"
}

resource "aws_apigatewayv2_route" "add-blog" {
  api_id    = aws_apigatewayv2_api.blog-api.id
  route_key = "POST /addblog"
  target    = "integrations/${aws_apigatewayv2_integration.add-blog.id}"
}

resource "aws_apigatewayv2_integration" "remove-blog" {
  api_id             = aws_apigatewayv2_api.blog-api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = "${aws_lambda_function.remove-blog.invoke_arn}"
}

resource "aws_apigatewayv2_route" "remove-blog" {
  api_id    = aws_apigatewayv2_api.blog-api.id
  route_key = "DELETE /removeblog"
  target    = "integrations/${aws_apigatewayv2_integration.remove-blog.id}"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id      = aws_apigatewayv2_api.blog-api.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_lambda_permission" "add-blog" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.add-blog.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.blog-api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "remove-blog" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.remove-blog.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.blog-api.execution_arn}/*/*"
}