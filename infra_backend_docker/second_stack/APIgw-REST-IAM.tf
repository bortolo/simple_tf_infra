resource aws_iam_role apigw_logs_role {
  name = "APIGatewayCloudWatchLogsRole"

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
  name = "APIGatewayCloudWatchLogsPolicy"
  role = aws_iam_role.apigw_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.apigw_logs_role.arn
    depends_on = [
    aws_iam_role_policy.apigw_logs_policy
  ]
}