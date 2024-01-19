################################################################################
# Common Variables
################################################################################
variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "organization" {
  description = "Name of the organization"
  type        = string
}

variable "aws_region" {
  description = "Region where to deploy the infrastructure"
  type        = string
}
variable "owner" {
  description = "Owner Name"
  type        = string
}

variable "oauth_client_id" {
  description = "Oauth client ID"
  type        = string
  sensitive   = true
}


################################################################################
# Backend CI/CD variables
################################################################################
variable "be_repository_name" {
  description = "Name of the git repository"
  type        = string
}

variable "be_repository_owner" {
  description = "Owner of the git repository"
  type        = string
}

variable "functions" {
  description = "List of functions and their configurations"

  type = list(object({
    name        = string
    handler     = string
    runtime     = string
    environment = map(string)
    http_method = string
    path_part   = string
    timeout     = number
  }))
}

variable "be_deployment_strategy" {
  type    = string
  default = "CodeDeployDefault.LambdaAllAtOnce"

  validation {
    condition = contains(
      [
        "CodeDeployDefault.LambdaAllAtOnce",
        "CodeDeployDefault.LambdaCanary10Percent5Minutes",
        "CodeDeployDefault.LambdaCanary10Percent10Minutes",
        "CodeDeployDefault.LambdaCanary10Percent15Minutes",
        "CodeDeployDefault.LambdaCanary10Percent30Minutes",
        "CodeDeployDefault.LambdaLinear10PercentEvery1Minute",
        "CodeDeployDefault.LambdaLinear10PercentEvery2Minutes",
        "CodeDeployDefault.LambdaLinear10PercentEvery3Minutes",
        "CodeDeployDefault.LambdaLinear10PercentEvery10Minutes"
    ], var.deployment_strategy)
    error_message = "Allowed values for input_parameter are listed here https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html#deployment-configuration-lambda"
  }
}
