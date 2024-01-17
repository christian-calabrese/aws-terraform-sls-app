################################################################################
# description of the common variables for all workspaces
################################################################################
locals {
  common_variables = {
    aws_region = var.aws_region
  }

  common_variables_descriptions = {
    environment = "Environment"
    project     = "Name of the project"
    aws_region  = "default region"
  }
}
