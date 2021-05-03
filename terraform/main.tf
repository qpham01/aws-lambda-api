provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "code_deploy" {
    bucket = "lamson-uswest2-code-deploy"

    # Prevent accidental deletion of this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    # Enable versioning so we can see the full revision history of our code files
    versioning {
        enabled = true
    }

    # Enable server-side encryption by default
    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_api_gateway_rest_api" "site_api" {
  name        = "site-api"
  description = "Website Api"
}

resource "aws_api_gateway_base_path_mapping" "site_api" {
  api_id      = "${aws_api_gateway_rest_api.site_api.id}"  
  stage_name  = "${aws_api_gateway_deployment.site_api.stage_name}"
}

resource "aws_api_gateway_deployment" "site_api" {
  depends_on = [
    aws_api_gateway_method.users_post,
    aws_api_gateway_integration.users_post,
    aws_api_gateway_method.authentication_post,
    aws_api_gateway_integration.authentication_post,
  ]
  rest_api_id       = "${aws_api_gateway_rest_api.site_api.id}"
  stage_name        = "application"
  stage_description = "1.0"
  description       = "1.0"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.site_api.root_resource_id}"
  path_part   = "users"
}

resource "aws_api_gateway_method" "users_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id   = "${aws_api_gateway_resource.users.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_post" {
  rest_api_id             = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id             = "${aws_api_gateway_resource.users.id}"
  http_method             = "${aws_api_gateway_method.users_post.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.users.arn}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "users_post_201" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id = "${aws_api_gateway_resource.users.id}"
  http_method = "${aws_api_gateway_method.users_post.http_method}"
  status_code = "201"
}

resource "aws_api_gateway_method_response" "users_post_400" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id = "${aws_api_gateway_resource.users.id}"
  http_method = "${aws_api_gateway_method.users_post.http_method}"
  status_code = "400"
}

resource "aws_api_gateway_resource" "authentication" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.site_api.root_resource_id}"
  path_part   = "authentication"
}

resource "aws_api_gateway_method" "authentication_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id   = "${aws_api_gateway_resource.authentication.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "authentication_post" {
  rest_api_id             = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id             = "${aws_api_gateway_resource.authentication.id}"
  http_method             = "${aws_api_gateway_method.authentication_post.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.authentication.arn}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "authentication_post_201" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id = "${aws_api_gateway_resource.authentication.id}"
  http_method = "${aws_api_gateway_method.authentication_post.http_method}"
  status_code = "201"
}

resource "aws_api_gateway_method_response" "authentication_post_400" {
  rest_api_id = "${aws_api_gateway_rest_api.site_api.id}"
  resource_id = "${aws_api_gateway_resource.authentication.id}"
  http_method = "${aws_api_gateway_method.authentication_post.http_method}"
  status_code = "400"
}

data "aws_s3_bucket_object" "s3_build_artifact_bucket" {
  bucket = "${aws_s3_bucket.code_deploy.bucket}"
  key    = "site-api/1.0/site-api.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "site-api-role"
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

resource "aws_lambda_function" "users" {
  function_name     = "site-api-users"
  role              = "${aws_iam_role.lambda_role.arn}"
  description       = "Users"
  handler           = "SiteApi::SiteApi.Function::Users"
  runtime           = "dotnetcore3.1"
  timeout           = 30
  s3_bucket         = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.bucket}"
  s3_key            = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.key}"
  s3_object_version = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.version_id}"
  environment {
    variables = {
      Environment = "${terraform.workspace}"      
    }
  }

  vpc_config {
    subnet_ids = [data.aws_subnet_ids.private.ids]
    security_group_ids = ["${aws_security_group.site_api.id}"]
  }
 
  tags = {
    Owner       = "Quoc Pham"
    Environment = "${terraform.workspace}"
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc.default"]
  }
}

data "aws_subnet" "private" {
  count = "${length(data.aws_subnet_ids.private.ids)}"
  id    = "${data.aws_subnet_ids.private.ids[count.index]}"
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}

resource "aws_security_group" "site_api" {
  name        = "site-api"
  description = "site api"
  vpc_id      = "${data.aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "private_egress_all" {
  type              = "egress"
  to_port           = 65535
  protocol          = "tcp"
  from_port         = 1024
  security_group_id = "${aws_security_group.site_api.id}"
  description       = "Private access to all"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lambda_permission" "authentication" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authentication.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:eu-west-2:000000000000:${aws_api_gateway_rest_api.site_api.id}/*/${aws_api_gateway_method.authentication_post.http_method}${aws_api_gateway_resource.authentication.path}"
}

resource "aws_lambda_function" "authentication" {
  function_name     = "site-api-authentication"
  role              = "${aws_iam_role.lambda_role.arn}"
  description       = "Authentication"
  handler           = "SiteApi::SiteApi.Function::Authentication"
  runtime           = "dotnetcore3.1"
  timeout           = 30
  s3_bucket         = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.bucket}"
  s3_key            = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.key}"
  s3_object_version = "${data.aws_s3_bucket_object.s3_build_artifact_bucket.version_id}"
  environment {
    variables = {
      Environment = "${terraform.workspace}"      
    }
  }
  
  vpc_config {
    subnet_ids = [data.aws_subnet_ids.private.ids]
    security_group_ids = ["${aws_security_group.site_api.id}"]
  }
 
  tags = {
    Owner       = "Quoc Pham"
    Environment = "${terraform.workspace}"
  }
}