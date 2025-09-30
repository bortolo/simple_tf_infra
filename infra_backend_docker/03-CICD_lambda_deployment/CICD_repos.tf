# Bucket S3 per la pipeline (memorizza artefatti pipeline)
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.bucket_name
  tags = local.tags
}

# ECR per l'immagine docker della lambda
resource "aws_ecr_repository" "lambda_container" {
  name                 = var.lambda_image_name
  image_tag_mutability = "MUTABLE"
  force_delete  = true
  
  tags = local.tags
}

resource "aws_ecr_repository_policy" "lambda_pull_policy" {
  repository = aws_ecr_repository.lambda_container.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "LambdaECRImageRetrievalPolicy"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Condition = {
          StringLike = {
            "aws:sourceArn" = "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:*"
          }
        }
      }
    ]
  })
}
