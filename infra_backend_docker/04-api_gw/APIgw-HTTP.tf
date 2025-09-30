#===================== HTTP =======
# Hai un API endpoint diretto (aws_apigatewayv2_api.public_api.api_endpoint) che puoi usare subito.
# Puoi fare curl verso quell’endpoint e funziona (anche con VPC endpoint) senza dover creare domain name, base path mapping, stage, ecc.
# La configurazione è più semplice, ma non puoi ancora usare resource policy per limitare accesso solo al VPCE via Terraform.

resource "aws_apigatewayv2_api" "public_api" {
  name          = var.apigw_http_name
  description   = "HTTP API pubblica per accesso esterno"
  protocol_type = "HTTP"
}

# Integrazione API → Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.public_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = data.aws_lambda_function.imported_lambda.invoke_arn
}

# Route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.public_api.id
  route_key = "GET /status"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.public_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvokeHTTP"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.imported_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.public_api.execution_arn}/*/*"
}