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