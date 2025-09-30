# General --------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_account" {
  type    = string
  default = "152371567679"
}

# Repos ----------------------------------------------------------
variable "github_url" {
  type    = string
}

variable "github_repo" {
  type    = string
}

variable "bucket_name" {
  type    = string
}

variable "lambda_image_name" {
  type    = string
}

# Build ---------------------------------------------------------
variable "build_name" {
  type    = string
}

variable "buildspec_file" {
  type    = string
}

variable "python_run_time" {
  type    = string
}

# Pipeline -----------------------------------------------------
variable "pipeline_name" {
  type    = string
}

