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
# WAF variables
################################################################################
variable "waf_rate_based_statement_limit" {
  description = "Rate limit for a single client IP calling the Api Gateway"
  type        = number
  default     = 100
}

variable "waf_log_retention_days" {
  description = "Days of WAF logs retention"
  type        = number
  default     = 7
}

