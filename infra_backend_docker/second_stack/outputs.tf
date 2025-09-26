output "lambda_function_prod_url" {
  value = aws_lambda_function_url.prod_url.function_url
}

output "lambda_function_test_url" {
  value = aws_lambda_function_url.test_url.function_url
}

output "http_api_invoke_url" {
  value = aws_apigatewayv2_api.public_api.api_endpoint
}