# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest/submodules/deploy?tab=inputs

module "alias_refresh" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  name          = "current-with-refresh"
  function_name = module.lambda_function.lambda_function_name

  # Set function_version when creating alias to be able to deploy using it,
  # because AWS CodeDeploy doesn't understand $LATEST as CurrentVersion.
  function_version = module.lambda_function.lambda_function_version
}

module "deploy" {
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name    = module.alias_refresh.lambda_alias_name
  function_name = module.lambda_function.lambda_function_name

  target_version = module.lambda_function.lambda_function_version

  create_app = true
  app_name   = "my-awesome-app"

  create_deployment_group = true
  deployment_group_name   = "something"

  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = true

  triggers = {
    start = {
      events     = ["DeploymentStart"]
      name       = "DeploymentStart"
      target_arn = "arn:aws:sns:eu-west-1:135367859851:sns1"
    }
    success = {
      events     = ["DeploymentSuccess"]
      name       = "DeploymentSuccess"
      target_arn = "arn:aws:sns:eu-west-1:135367859851:sns2"
    }
  }
}
