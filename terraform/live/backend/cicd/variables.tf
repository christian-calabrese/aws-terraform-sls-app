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
  }))
}
