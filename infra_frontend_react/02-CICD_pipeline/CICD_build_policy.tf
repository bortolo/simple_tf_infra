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
resource "aws_iam_role_policy" "build_role" {
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
          "s3:GetObjectVersion",
          "s3:DeleteObject"
          ]
        Resource = [
          "${data.aws_s3_bucket.bucket.arn}/*",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
            {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket"
          ]
        Resource = [
          "${data.aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}


# RESOURCE POLICY ===========================================================