#######################################################################################
# LAMBDA
#######################################################################################

# Crea la Lambda function (assumi che l'handler e il ruolo siano già definiti)
# Per la prima creazione un pacchetto fittizio bulid_output.zip deve essere definito 
# Non cambiare il nome, se occorre farlo ricordarsi di aggiornare anche buildspec.yml
resource "aws_lambda_function" "my_lambda" {
  filename         = "./resources/lambda_package.zip" #dummy code to build the very first lambda
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"

  layers = [
    aws_lambda_layer_version.plotly_pandas_numpy.arn
  ]

  environment {
    variables = {ListOfUsers_table = aws_dynamodb_table.ListOfUsers.name}
}
  tags = local.tags
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.my_lambda.function_name
  authorization_type = "NONE"  # o "AWS_IAM"
}

resource "aws_lambda_layer_version" "plotly_pandas_numpy" {
  layer_name  = "plotly_pandas_numpy"
  description = "Layer con pandas e plotly"
  compatible_runtimes = ["python3.9"]
  s3_bucket   = var.bucket_name
  s3_key      = "layer.zip"
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