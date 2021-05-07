resource "aws_dynamodb_table" "blog-example" {
  name         = "lamson-usw2-blog-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}