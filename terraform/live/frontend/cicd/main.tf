resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}-${var.environment}-frontend-pipeline"
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
        ConnectionArn    = data.tfe_outputs.frontend.values.aws_codestarconnections_connection_github_arn
        FullRepositoryId = "${var.fe_repository_owner}/${var.fe_repository_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["source_output"]
      version         = 1

      configuration = {
        BucketName = data.tfe_outputs.frontend.values.fe_s3_bucket_name
        Extract    = true
      }
    }
  }

  stage {
    name = "Invoke"

    action {
      name     = "InvalidateCloudfrontCache"
      category = "Invoke"
      owner    = "AWS"
      provider = "Lambda"
      version  = 1

      configuration = {
        FunctionName = aws_lambda_function.create_invalidation.function_name
      }
    }
  }
}
