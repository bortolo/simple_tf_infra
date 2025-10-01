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

variable "branch" {
  type    = string
}

# Build ---------------------------------------
variable "build_name" {
  type    = string
}

variable "nodejs_runtime" {
  type    = number
}

variable "buildspec_file" {
  type    = string
}

# Pipeline -----------------------------------------------------
variable "pipeline_name" {
  type    = string
}

variable "bucket_name_pipeline" {
  type    = string
}
