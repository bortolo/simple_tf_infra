# WEB ACCESS POLICY -----------------------------------------
resource "aws_s3_bucket_public_access_block" "spa" {
  bucket = aws_s3_bucket.spa_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# IAM POLICY --------------------------------------------

# RESOURCE POLICY ----------------------------------------
resource "aws_s3_bucket_policy" "spa_policy" {
  bucket = aws_s3_bucket.spa_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.spa_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.spa]
}