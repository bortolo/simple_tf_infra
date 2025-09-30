# General variables ----------------------------------
variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_account" {
  type    = string
  default = "152371567679"
}

# APIgw-HTTP -----------------------------------------
variable "apigw_http_name" {
  type    = string
  default = "my-public-api"
}

# APIgw-REST -----------------------------------------
variable "apigw_rest_name" {
  type    = string
  default = "my-private-api"
}

variable "apigw_rest_paths" {
  type = map(object({
    resource   = string
    method     = string
  }))
}

variable "apigw_rest_stages" {
  type = map(string)
}