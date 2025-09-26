#######################################################################################
# LAMBDA
#######################################################################################

data "aws_dynamodb_table" "ListOfUsers" {
  name = "ListOfUsers"
}

# Version lambda con docker
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_container"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.lambda_container.repository_url}:test"  # placeholder
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {ListOfUsers_table = data.aws_dynamodb_table.ListOfUsers.name}
  }
  tags = local.tags
}

# Alias lambda prod
resource "aws_lambda_alias" "prod_lambda_alias" {
  name             = "prod"
  description      = "Alias for production"
  function_name    = aws_lambda_function.my_lambda.arn
  function_version = "5"
}

# Function URL per alias prod
resource "aws_lambda_function_url" "prod_url" {
  function_name      = aws_lambda_alias.prod_lambda_alias.arn
  authorization_type = "NONE"
}

# Alias lambda test
resource "aws_lambda_alias" "test_lambda_alias" {
  name             = var.test_alias
  description      = "Alias for test"
  function_name    = aws_lambda_function.my_lambda.arn
  function_version = "6"
}

# Function URL per alias test
resource "aws_lambda_function_url" "test_url" {
  function_name      = aws_lambda_alias.test_lambda_alias.arn
  authorization_type = "NONE"  # o "AWS_IAM"
}