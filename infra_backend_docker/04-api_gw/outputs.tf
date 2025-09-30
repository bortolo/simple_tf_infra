output "http_api_invoke_url" {
  value = aws_apigatewayv2_api.public_api.api_endpoint
}

output "rest_api_invoke_url" {
  value = { for k, v in aws_api_gateway_stage.all : k => v.invoke_url }
}