resource "aws_lambda_function" "add-blog" {
  filename          = "build.zip"
  function_name     = "AddBlogAsync"
  role              = aws_iam_role.lambda-iam.arn
  handler           = "ExampleApi::ExampleApi.Functions::AddBlogAsync"
  runtime           = "dotnetcore3.1"
  source_code_hash  = "${filebase64sha256("build.zip")}"
  timeout           = 60

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [data.aws_security_group.default.id]        
  }
  
  environment {
    variables = {
      BlogTable = "lamson-usw2-blog-table"
    }
  }
}


resource "aws_lambda_function" "remove-blog" {
  filename          = "build.zip"
  function_name     = "RemoveBlogAsync"
  role              = aws_iam_role.lambda-iam.arn
  handler           = "ExampleApi::ExampleApi.Functions::RemoveBlogAsync"
  runtime           = "dotnetcore3.1"
  source_code_hash  = "${filebase64sha256("build.zip")}"
  timeout           = 60

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [data.aws_security_group.default.id]        
  }
  
  environment {
    variables = {
      BlogTable = "lamson-usw2-blog-table"
    }
  }
}