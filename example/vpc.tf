data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_security_group" "default" {
  id = var.security_group_id
}

resource aws_vpc_endpoint dynamodb {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.us-west-2.dynamodb"
  route_table_ids   = [var.route_table_id] 
}