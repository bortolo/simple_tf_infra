######################################################################################
# CODEPIPELINE - IAM
######################################################################################

# Crea il ruolo IAM per CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

    tags = local.tags
}

# Attacca policy al ruolo di CodePipeline
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
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
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateAlias"
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
        Effect   = "Allow",
        Action   = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "codestar-connections:*"
        ],
        Resource = "*"
      }
    ]
  })
}