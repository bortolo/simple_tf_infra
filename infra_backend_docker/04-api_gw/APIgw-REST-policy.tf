# ROLE POLICY ===========================================================

resource aws_iam_role apigw_logs_role {
  name = "${var.apigw_rest_name}-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource aws_iam_role_policy apigw_logs_policy {
  name = "${var.apigw_rest_name}-Policy"
  role = aws_iam_role.apigw_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Non riesce a creare questa risorsa!!!!!!!
resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.apigw_logs_role.arn
    depends_on = [
    aws_iam_role_policy.apigw_logs_policy
  ]
}

# RESOURCE POLICY ===========================================================

# from VPCe to APIgw
resource "aws_api_gateway_rest_api_policy" "private_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:${var.aws_region}:${var.aws_account}:${aws_api_gateway_rest_api.private_api.id}/*/*/*"
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = "${aws_vpc_endpoint.api_gw.id}"
          }
        }
      }
    ]
  })
}

# from APIgw to lambda
resource "aws_lambda_permission" "apigw_rest" {
  for_each = var.imported_lambda_alias

  statement_id  = "AllowAPIGatewayInvokeREST${each.value}"
  action        = "lambda:InvokeFunction"
  # function_name = "${data.aws_lambda_function.imported_lambda.arn}:${each.value}"
  function_name = data.aws_lambda_function.imported_lambda.function_name
  qualifier     = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.private_api.execution_arn}/*/*" # Questo permette qualsiasi stage e qualsiasi metodo della tua API di invocare la Lambda
}