# ROLE POLICY =======================================================

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
    tags = local.tags
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  role = aws_iam_role.lambda_exec.id
  name = "${var.lambda_name}-Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource": "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        "Action": [
          "dynamodb:Scan",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "dynamodb:GetResourcePolicy",
          "dynamodb:Query",
          "dynamodb:PartiQLSelect",
          "dynamodb:DeleteItem",
          "dynamodb:DeleteTable",
          "dynamodb:*"
        ],
        "Resource": "arn:aws:dynamodb:*:152371567679:table/*",
        "Effect": "Allow"
      }
    ]
  })
}

# RESOURCE POLICY =======================================================