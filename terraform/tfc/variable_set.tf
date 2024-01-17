################################################################################
# Variable Set - Common
################################################################################
module "common" {
  source  = "flowingis/variable-set/tfe"
  version = "0.3.1"

  name         = "${var.project}-common"
  organization = var.organization
  description  = "Common variables for ${var.project}"
  global       = true


  terraform_variables = {
    organization = var.organization
  }

  terraform_sensitive_variables = {
    oauth_client_id = var.oauth_client_id
  }

  environment_sensitive_variables = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_access_key_secret
  }

  variables_descriptions = {
    organization          = "Name of the organization"
    oauth_client_id       = "Oauth client ID"
    AWS_ACCESS_KEY_ID     = "Access Key ID to access AWS Account"
    AWS_SECRET_ACCESS_KEY = "Secret Access Key to access AWS Account"
  }
}
