#######################################################################################
# CODEBUILD - IAM
#######################################################################################

# Crea il ruolo IAM per codebuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.codebuild_name}-exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
    tags = local.tags
}

# Attacca policy al ruolo di codebuild
resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction",
          "lambda:PublishVersion",
          "lambda:ListVersionsByFunction",
          "lambda:UpdateAlias"
        ],
        Resource = "${aws_lambda_function.my_lambda.arn}"
      },
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = "*"
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
        Effect  = "Allow",
        Action  = [
           "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}