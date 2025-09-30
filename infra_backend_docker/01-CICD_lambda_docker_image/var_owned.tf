# General --------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "eu-central-1"
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
  default = "my-codepipeline-bucket-developercourse-experiments-3"
}

variable "lambda_image_name" {
  type    = string
}

# Build first docker image ---------------------------------------
variable "docker_build_name" {
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

