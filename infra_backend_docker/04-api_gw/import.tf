
data "aws_lambda_function" "imported_lambda" {
  function_name = var.imported_lambda_name
}

data "aws_vpc" "imported_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.imported_vpc_name]
  }
}

data "aws_subnets" "imported_vpc_subnets" {
    filter {
    name   = "vpc-id"
    values = [data.aws_vpc.imported_vpc.id]
  }
}