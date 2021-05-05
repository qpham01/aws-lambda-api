provider "aws" {
  region = "us-west-2"
}

# Comment this out and run terraform init and terraform apply
# Then comment it in and run terraform init to set up remote s3 state

terraform {
  backend "s3" {
    bucket         = "lamson-usw2-tfstate"
    key            = "example/api-lambda.tfstate"
    region         = "us-west-2"
    dynamodb_table = "lamson-usw2-s3locks"
    encrypt        = true
  }
}