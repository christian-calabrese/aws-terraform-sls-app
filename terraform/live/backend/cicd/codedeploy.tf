module "alias_refresh" {
  for_each = data.data.tfe_outputs.backend.values.functions_information
  source   = "terraform-aws-modules/lambda/aws//modules/alias"

  name          = "current-with-refresh"
  function_name = each.key

  # Set function_version when creating alias to be able to deploy using it,
  # because AWS CodeDeploy doesn't understand $LATEST as CurrentVersion.
  function_version = each.value.lambda_function_version
}

module "deploy" {
  for_each = data.data.tfe_outputs.backend.values.functions_information
  source   = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name    = module.alias_refresh[each.key].lambda_alias_name
  function_name = each.value.lambda_function_name

  target_version = each.value.lambda_function_version

  create_app = true
  app_name   = "${var.project}-${var.environment}-${each.key}"

  create_deployment_group = true
  deployment_group_name   = each.key

  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = true

  alarm_enabled = length(data.tfe_outputs.backend.values.alarm_names) > 0
  alarms        = data.tfe_outputs.backend.values.alarm_names
}
