variable "aws_region" {
  default     = "us-west-2"
  description = "AWS Region to deploy example API Gateway HTTP API"
  type        = string
}

variable "http_api_domain_name" {
  default     = "api.highmoontech.com"
  description = "Domain name of the API Gateway HTTP API"
  type        = string
}

variable "http_api_name" {
  default     = "http-api-example"
  description = "Name of the API Gateway HTTP API (can be used to trigger redeployments)"
  type        = string
}

variable "http_api_path" {
  default     = "/path"
  description = "Path to create in the API Gateway HTTP API (can be used to trigger redeployments)"
  type        = string
}

variable "vpc_id" {
  default     = "vpc-aea68ed6"
  type        = string
}

variable "subnet_id_0" {
  default     = "subnet-c5b3158f"
  type        = string
}

variable "subnet_ids" {
  default     = ["subnet-c5b3158f","subnet-f94748d2","subnet-2246c35a","subnet-5efc6b03"]
  type        = list(string)
}

variable "security_group_id" {
  default     = "sg-94c3f5ab"
  type        = string
}

variable "route_table_id" {
  default     = "rtb-a43520df"
  type        = string
}