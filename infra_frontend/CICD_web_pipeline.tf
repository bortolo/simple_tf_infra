#######################################################################################
# CODEPIPELINE 
#######################################################################################

# Bucket S3 per artifact store
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.bucket_name
  tags = local.tags
}

# Connessione a github (la connessione deve essere già disponibile per questa region)
data "aws_codestarconnections_connection" "example" {
  name = var.github_connection_name
}

# Definisci il CodePipeline
resource "aws_codepipeline" "my_pipeline" {
  name     = var.pipeline_name
  pipeline_type = "V2"
  execution_mode = "QUEUED"
  role_arn = aws_iam_role.codepipeline_role.arn
  

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
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
        ConnectionArn        = data.aws_codestarconnections_connection.example.arn
        FullRepositoryId     = var.github_repo
        BranchName           = "main"
        # DetectChanges        = true
        # OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  # Fase di deploy
  stage {
    name = "Deploy"

    action {
      name             = "DeployToEC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["source_output"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.foo_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.foo.deployment_group_name
      }
    }
  }

  tags = local.tags

}