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
  image_uri     = "${data.aws_ecr_repository.lambda_container.repository_url}:latest"  # placeholder
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {ListOfUsers_table = data.aws_dynamodb_table.ListOfUsers.name}
  }
  tags = local.tags
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.my_lambda.function_name
  authorization_type = "NONE"  # o "AWS_IAM"
}


resource "aws_lambda_alias" "prod_lambda_alias" {
  name             = "prod"
  description      = "Alias for production"
  function_name    = aws_lambda_function.my_lambda.arn
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "test_lambda_alias" {
  name             = var.test_alias
  description      = "Alias for test"
  function_name    = aws_lambda_function.my_lambda.arn
  function_version = "$LATEST"
}