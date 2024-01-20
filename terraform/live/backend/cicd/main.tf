resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}-${var.environment}-backend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      output_artifacts = ["source_output"]
      version          = 1

      configuration = {
        BranchName       = { dev = "develop", prod = "main" }[var.environment]
        ConnectionArn    = data.tfe_outputs.backend.values.aws_codestarconnections_connection_github_arn
        FullRepositoryId = "${var.be_repository_owner}/${var.be_repository_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    dynamic "action" {
      for_each = nonsensitive(data.tfe_outputs.backend.values.functions_information)

      content {
        name            = "Deploy_${action.key}"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        input_artifacts = ["source_output"]
        version         = 1

        configuration = {
          ApplicationName     = module.deploy[action.key].codedeploy_app_name
          DeploymentGroupName = module.deploy[action.key].codedeploy_deployment_group_name
        }
      }
    }
  }
}
