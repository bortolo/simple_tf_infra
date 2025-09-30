# General -------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_account" {
  type    = string
  default = "152371567679"
}

# Lambda ---------------------------------------------------------
variable "lambda_name" {
  type    = string
  default = "my_lambda_function"
}

variable "lambda_alias" {
  type    = map(string)
}