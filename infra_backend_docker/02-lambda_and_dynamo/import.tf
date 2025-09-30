data "aws_ecr_repository" "lambda_container" {
  name = var.lambda_image_name
}