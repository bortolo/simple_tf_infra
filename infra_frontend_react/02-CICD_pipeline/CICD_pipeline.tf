# Bucket S3 per la pipeline (memorizza artefatti pipeline)
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.bucket_name_pipeline
  tags = local.tags
}

# Definisci il CodePipeline
resource "aws_codepipeline" "my_pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  # Bucket S3 dove salvare gli artifacts
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  # Fase di origine (Source) da GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.example.arn
        FullRepositoryId = var.github_repo
        BranchName       = var.branch
      }
    }
  }

  # Fase di build zip con requirements e invio a lambda function
  stage {
    name = "BuildAndDeploy"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_test_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_react.name
      }
    }
  }

  tags = local.tags

}