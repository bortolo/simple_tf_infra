resource "aws_codebuild_project" "build_docker_image" {
  name         = var.docker_build_name
  description  = "Builds Python docker image for Lambda and push it to ECR"
  service_role = aws_iam_role.build_docker_image_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
        name  = "ECR_REPOSITORY"
        value = aws_ecr_repository.lambda_container.repository_url
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "ENV"
        value = "first"
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "LAMBDA_PY_RUNTIME"
        value = var.python_run_time
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "AWS_REGION"
        value = var.aws_region
        type  = "PLAINTEXT"
    }

  }

  source {
    type = "CODEPIPELINE"
    buildspec = var.buildspec_file
  }
}