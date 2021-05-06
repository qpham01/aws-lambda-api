resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  managed_policy_arns = ["arn:aws:iam::115648203036:policy/service-role/AWSLambdaEdgeExecutionRole-d15dbb38-5efb-4b5b-84cb-1e421124d709"]
}

resource "aws_lambda_function" "add-blog" {
  filename          = "build.zip"
  function_name     = "AddBlogAsync"
  role              = aws_iam_role.lambda_iam.arn
  handler           = "ExampleApi::ExampleApi.Functions::AddBlogAsync"
  runtime           = "dotnetcore3.1"
}

resource "aws_apigatewayv2_api" "example" {
  name          = var.http_api_name
  protocol_type = "HTTP"
  target        = aws_lambda_function.add-blog.arn
}

# resource "aws_apigatewayv2_stage" "example-dev" {
#   api_id = aws_apigatewayv2_api.example.id
#   name   = "example-dev"
# }

resource "aws_lambda_permission" "add-blog" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.add-blog.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.example.execution_arn}/*/*"
}

# resource "aws_apigatewayv2_api_mapping" "example-dev" {
#   api_id      = aws_apigatewayv2_api.example.id
#   domain_name = aws_apigatewayv2_domain_name.example.id
#   stage       = aws_apigatewayv2_stage.example-dev.id
# }