
# Version lambda con docker
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_name
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.lambda_container.repository_url}:first"  # placeholder
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {DYNAMODB_TABLE = aws_dynamodb_table.scenarios.name}
  }

  lifecycle {
    ignore_changes = [image_uri] # attenzione questa variabile dopo la prima creazione sarà gestita dai buildspec della pipeline
  }

  tags = local.tags
}

resource "aws_lambda_alias" "all" {
  for_each = var.lambda_alias

  name             = each.value
  description      = "Alias for ${each.value}"
  function_name    = aws_lambda_function.my_lambda.arn
  function_version = "$LATEST"

  lifecycle {
    ignore_changes = [function_version] # attenzione questa variabile dopo la prima creazione sarà gestita dai buildspec della pipeline
  }
}

resource "aws_lambda_function_url" "all" {
  for_each = aws_lambda_alias.all

  function_name      = each.value.arn
  authorization_type = "NONE"
}