################################################################################
# Network Workspaces
################################################################################
module "sls-app-network-eu-south-1-prod" {
  source  = "flowingis/workspace/tfe"
  version = "0.5.0"

  name                      = "${var.project}-network-${var.aws_region}-prod"
  organization              = var.organization
  description               = "Common network resources for the production environment"
  terraform_version         = "1.3.9"
  execution_mode            = "remote"
  queue_all_runs            = false
  working_directory         = "terraform/live/network"
  vcs_repository_identifier = "${var.owner}/aws-terraform-sls-app"
  vcs_repository_branch     = "main"
  oauth_token_id            = var.oauth_client_id

  environment_sensitive_variables = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_access_key_secret
  }

  terraform_variables = {
    vpc_cidr               = "172.31.0.0/16"
    vpc_enable_nat_gateway = false
    vpc_single_nat_gateway = false
    environment            = "prod"
  }

  terraform_hcl_variables = {
    vpc_public_subnets   = ["172.31.1.0/24", "172.31.2.0/24", "172.23.3.0/24"]
    vpc_private_subnets  = ["172.31.10.0/24", "172.31.11.0/24", "172.31.12.0/24"]
    vpc_database_subnets = ["172.31.20.0/24", "172.31.21.0/24", "172.31.22.0/24"]
  }

  variables_descriptions = {
    vpc_cidr = "The CIDR of the VPC"

    vpc_public_subnets   = "List of CIDRs for VPC public subnets"
    vpc_database_subnets = "List of CIDRs for VPC database subnets"
    vpc_private_subnets  = "List of CIDRs for VPC private subnets"
  }

  tag_names = ["region:${var.aws_region}", "environment:prod", "project:${var.project}", "provider:aws", "component:network"]

}

################################################################################
# Frontend Workspaces
################################################################################
module "sls-app-frontend-eu-south-1-prod" {
  source  = "flowingis/workspace/tfe"
  version = "0.5.0"

  name                      = "${var.project}-frontend-${var.aws_region}-prod"
  organization              = var.organization
  description               = "Common frontend resources for the production environment"
  terraform_version         = "1.3.9"
  execution_mode            = "remote"
  queue_all_runs            = false
  working_directory         = "terraform/live/frontend"
  vcs_repository_identifier = "${var.owner}/aws-terraform-sls-app"
  vcs_repository_branch     = "main"
  oauth_token_id            = var.oauth_client_id

  environment_sensitive_variables = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_access_key_secret
  }

  terraform_variables = {
    environment = "prod"
  }

  tag_names = ["region:${var.aws_region}", "environment:prod", "project:${var.project}", "provider:aws", "component:frontend"]

}

################################################################################
# Backend Workspaces
################################################################################
module "sls-app-backend-eu-south-1-prod" {
  source  = "flowingis/workspace/tfe"
  version = "0.5.0"

  name                      = "${var.project}-backend-${var.aws_region}-prod"
  organization              = var.organization
  description               = "Common backend resources for the production environment"
  terraform_version         = "1.3.9"
  execution_mode            = "remote"
  queue_all_runs            = false
  working_directory         = "terraform/live/backend"
  vcs_repository_identifier = "${var.owner}/aws-terraform-sls-app"
  vcs_repository_branch     = "main"
  oauth_token_id            = var.oauth_client_id

  environment_sensitive_variables = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_access_key_secret
  }

  terraform_variables = {
    environment = "prod"
  }

  tag_names = ["region:${var.aws_region}", "environment:prod", "project:${var.project}", "provider:aws", "component:backend"]

}

