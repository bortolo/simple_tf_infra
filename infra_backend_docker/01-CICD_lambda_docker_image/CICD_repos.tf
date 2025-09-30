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