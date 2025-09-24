output "lambda_function_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}

output "http_api_invoke_url" {
  value = aws_apigatewayv2_api.public_api.api_endpoint
}