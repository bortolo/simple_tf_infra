# Connessione a github (la connessione deve essere già disponibile per questa region)
data "aws_codestarconnections_connection" "example" {
  name = var.github_connection_name
}

data "aws_lambda_function" "my_lambda" {
  function_name = var.imported_lambda_name
}