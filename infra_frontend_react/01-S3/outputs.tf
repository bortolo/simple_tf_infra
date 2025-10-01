output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.spa_conf.website_endpoint
}