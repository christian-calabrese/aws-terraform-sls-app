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

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = 1

      configuration = {
        BucketName = data.tfe_outputs.frontend.values.fe_s3_bucket_name
        Extract    = true
      }
    }
  }
}
