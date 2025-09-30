resource "aws_codebuild_project" "build_test" {
  name         = "${var.build_name}-test"
  description  = "Builds test Python docker image for Lambda and push it to ECR and update lambda test alias"
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
        name  = "ECR_REPOSITORY"
        value = aws_ecr_repository.lambda_container.repository_url
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "ECR_IMAGE"
        value = aws_ecr_repository.lambda_container.name
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "LAMBDA_ARN"
        value = data.aws_lambda_function.my_lambda.arn
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "ENV"
        value = "test"
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

resource "aws_codebuild_project" "build_prod" {
  name         = "${var.build_name}-prod"
  description  = "Builds test Python docker image for Lambda and push it to ECR and update lambda prod alias"
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
        name  = "ECR_REPOSITORY"
        value = aws_ecr_repository.lambda_container.repository_url
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "ECR_IMAGE"
        value = aws_ecr_repository.lambda_container.name
        type  = "PLAINTEXT"
    }
    
    environment_variable {
        name  = "LAMBDA_ARN"
        value = data.aws_lambda_function.my_lambda.arn
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "ENV"
        value = "prod"
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