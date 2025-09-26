######################################################################################
# CODE BUILD - LAYERS - IAM
#######################################################################################


# Role per CodeBuild
resource "aws_iam_role" "codebuild_role_layers" {
  name = "codebuild-docker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policy per permettere upload su S3
resource "aws_iam_role_policy" "codebuild_policy_layers" {
  role = aws_iam_role.codebuild_role_layers.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject", 
          "s3:GetObject", 
          "s3:GetObjectVersion"
          ]
        Resource = "${aws_s3_bucket.codepipeline_bucket.arn}/*"
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
          "lambda:PublishLayerVersion",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetLayerVersion",
          "lambda:UpdateFunctionCode",
          "lambda:PublishVersion",
          "lambda:UpdateAlias",
          "lambda:GetFunctionConfiguration"
        ],
        Resource = "*"
      },
      {
        Effect  = "Allow",
        Action  = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:DescribeRepositories",
            "ecr:CreateRepository"
        ],
        Resource = "*"
    }
    ]
  })
}