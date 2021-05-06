resource "aws_iam_role" "lambda-iam" {
  name = "lambda-iam"

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
}

resource "aws_iam_policy" "log-all" {
  name = "log-all"
  description = "Log to all"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "log-attach" {
  role       = "${aws_iam_role.lambda-iam.name}"
  policy_arn = "${aws_iam_policy.log-all.arn}"
}

resource "aws_lambda_function" "add-blog" {
  filename          = "build.zip"
  function_name     = "AddBlogAsync"
  role              = aws_iam_role.lambda-iam.arn
  handler           = "ExampleApi::ExampleApi.Functions::AddBlogAsync"
  runtime           = "dotnetcore3.1"
  source_code_hash  = "${filebase64sha256("build.zip")}"
}

resource "aws_apigatewayv2_api" "example" {
  name          = var.http_api_name
  protocol_type = "HTTP"
  target        = aws_lambda_function.add-blog.arn
  route_key     = "POST /addblog"
}

resource "aws_lambda_permission" "add-blog" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.add-blog.arn
	principal     = "apigateway.amazonaws.com"

	source_arn = "${aws_apigatewayv2_api.example.execution_arn}/*/*"
}