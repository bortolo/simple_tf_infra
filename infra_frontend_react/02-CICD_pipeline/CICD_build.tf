resource "aws_codebuild_project" "build_react" {
  name         = var.build_name
  description  = "Builds react artifacts and push them on s3"
  service_role = aws_iam_role.build_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
        name  = "AWS_REGION"
        value = var.aws_region
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "NODEJS_RUNTIME"
        value = var.nodejs_runtime
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "S3_BUCKET"
        value = var.bucket_name
        type  = "PLAINTEXT"
    }

  }

  source {
    type = "CODEPIPELINE"
    buildspec = var.buildspec_file
  }
}