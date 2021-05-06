# output "curl_domain_url" {
#   depends_on = [aws_apigatewayv2_api_mapping.example-dev]

#   description = "API Gateway Domain URL"
#   value       = "curl -H 'Host: ${var.http_api_domain_name}' https://${aws_apigatewayv2_domain_name.example.domain_name} # may take a minute to become available on initial deploy"
# }

# output "curl_stage_invoke_url" {
#   description = "API Gateway Stage Invoke URL"
#   value       = "curl ${aws_apigatewayv2_stage.example-dev.invoke_url}"
# }