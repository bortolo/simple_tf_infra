######################################################################################
# CODE BUILD - LAYERS
#######################################################################################

# CodeBuild project per creare il layer
resource "aws_codebuild_project" "layer_build" {
  name         = var.codebuild_name_layer
  description  = "Builds Python layer for Lambda"
  service_role = aws_iam_role.codebuild_role_layers.arn

  # artifacts {
  #   type = "S3"
  #   location = aws_s3_bucket.codepipeline_bucket.bucket
  #   packaging = "ZIP"
  #   path      = var.layer_s3_path
  #   name      = "*_layer.zip"
  # }

  artifacts {
  type = "NO_ARTIFACTS"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true




    environment_variable {
        name  = "S3_BUCKET"
        value = aws_s3_bucket.codepipeline_bucket.bucket
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "LAYER_S3_PATH"
        value = var.layer_s3_path
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "LAMBDA_ARN"
        value = aws_lambda_function.my_lambda.arn
        type  = "PLAINTEXT"
    }

    environment_variable {
        name  = "LIBS_LAYER"
        value = var.libs_layers
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

    environment_variable {
        name  = "LAYER_FILE_NAME"
        value = var.layer_name
        type  = "PLAINTEXT"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("./resources/layers/buildspec.yml")
  }
}