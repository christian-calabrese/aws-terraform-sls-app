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
# Frontend variables
################################################################################
variable "fe_bucket_force_destroy" {
  description = "The flag that indicates all objects should be deleted from the bucket"
  default     = false
}

variable "fe_bucket_enable_versioning" {
  description = "The flag if bucket versioning is enabled"
  default     = true
}

variable "fe_domain_name" {
  description = "Domain name for the cloudfront distribution"
  default     = null
}

variable "fe_alias" {
  description = "Aliases for the cloudfront domain"
  default     = null
}

variable "fe_min_ttl" {
  default = 0
}

variable "fe_default_ttl" {
  default = 3600
}

variable "fe_max_ttl" {
  default = 86400
}
