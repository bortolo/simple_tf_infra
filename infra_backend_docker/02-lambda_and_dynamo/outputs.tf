output "lambda_urls" {
  value = { for k, v in aws_lambda_function_url.all : k => v.function_url }
}