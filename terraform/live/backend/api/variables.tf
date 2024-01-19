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
# Backend variables
################################################################################
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

variable "domain_name" {
  description = "The domain name used to publish the api gateway"
  type        = string
  default     = null
}

variable "api_gateway_scope" {
  description = "The scope of the api gateway. It can be REGIONAL or EDGE"
  type        = string
  default     = "REGIONAL"
}
