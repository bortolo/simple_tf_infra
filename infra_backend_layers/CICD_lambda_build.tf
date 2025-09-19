#######################################################################################
# CODEBUILD
#######################################################################################

# Progetto CodeBuild
resource "aws_codebuild_project" "lambda_build" {
  name          = "lambda_build"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"

    environment_variable {
        name  = "LAMBDA_FUNCTION_NAME"
        value = var.lambda_name
        type  = "PLAINTEXT"
      }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = local.tags
}