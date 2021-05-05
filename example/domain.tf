resource "aws_apigatewayv2_domain_name" "example" {
  domain_name              = var.http_api_domain_name

  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-west-2:115648203036:certificate/8b1dce78-ff10-427c-8871-a7e3dabb9ce9"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "example" {
  name    = aws_apigatewayv2_domain_name.example.domain_name
  type    = "A"
  zone_id = "Z04005631RWEJQ6RE7XKE"

  alias {
    name                   = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}