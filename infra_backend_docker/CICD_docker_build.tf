######################################################################################
# CODE BUILD - DOCKER IMAGE
#######################################################################################

resource "aws_ecr_repository" "lambda_container" {
  name                 = "my-lambda-image"
  image_tag_mutability = "MUTABLE"
  force_delete  = true
  tags = local.tags
}

# CodeBuild project per creare il layer
resource "aws_codebuild_project" "docker_build" {
  name         = var.codebuild_name
  description  = "Builds Python docker image for Lambda"
  service_role = aws_iam_role.codebuild_role_layers.arn

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
    buildspec = "buildspec_docker.yml"
  }
}


# CodeBuild project per creare il layer
resource "aws_codebuild_project" "docker_build_prod" {
  name         = "${var.codebuild_name}-prod"
  description  = "Builds Python docker image and push into production Lambda"
  service_role = aws_iam_role.codebuild_role_layers.arn

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
    buildspec = "buildspec_deploy_docker.yml"
  }
}