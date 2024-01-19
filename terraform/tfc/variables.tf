################################################################################
# Common Variables
################################################################################
variable "organization" {
  description = "Name of the organization"
  type        = string
}

variable "aws_region" {
  description = "Default Region"
  type        = string
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "sls-app"
}

variable "owner" {
  description = "Owner Name"
  type        = string
  default     = "christian-calabrese"
}

variable "oauth_client_id" {
  description = "Oauth client ID"
  type        = string
  sensitive   = true
}

variable "tfe_token" {
  description = "TFE Token"
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "Name of the git repository"
  type        = string
  default     = "aws-terraform-sls-app"
}


################################################################################
# Variable Set
################################################################################
variable "aws_access_key_id" {
  type        = string
  description = "Access Key ID to access AWS Account"
  sensitive   = true
}

variable "aws_access_key_secret" {
  type        = string
  description = "Secret Access Key to access AWS Account"
  sensitive   = true
}
