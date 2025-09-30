# ROLE POLICY ===========================================================

resource "aws_iam_role" "build_role" {
  name = "${var.build_name}-Role"

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
resource "aws_iam_role_policy" "build_policy" {
  role = aws_iam_role.build_role.id
  name = "${var.build_name}-Policy"

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


# RESOURCE POLICY ===========================================================