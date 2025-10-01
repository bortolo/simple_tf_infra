# Bucket S3 per artifact store
resource "aws_s3_bucket" "spa_bucket" {
  bucket = var.bucket_name

  tags = local.tags
}

# Configurazione static website
resource "aws_s3_bucket_website_configuration" "spa_conf" {
  bucket = aws_s3_bucket.spa_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}