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

variable "subdomain_name" {
  description = "value"
  type        = string
  default     = "api"
}

variable "api_gateway_scope" {
  description = "The scope of the api gateway. It can be REGIONAL or EDGE"
  type        = string
  default     = "REGIONAL"
}


variable "api_gateway_metrics_to_alarm" {
  description = "Dictionary containing information of cloudwatch metrics to be alarmed"
  type = list(object({
    metric_name        = string
    evaluation_periods = number
    period             = number
    threshold          = number
    statistic          = string
  }))
}

variable "support_email_list" {
  description = "List of emails of on call support who will receive alarm notifications"
  type        = list(string)
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode can be either PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB billing mode can be either PROVISIONED or PAY_PER_REQUEST"
  type        = number
  default     = null
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB billing mode can be either PROVISIONED or PAY_PER_REQUEST"
  type        = number
  default     = null
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

