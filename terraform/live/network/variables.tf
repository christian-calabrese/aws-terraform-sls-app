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
# VPC Modules variables
################################################################################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
}

################################################################################
# Route53
################################################################################
variable "domain_name" {
  description = "The domain name used to publish the api gateway"
  type        = string
  default     = null
}

variable "create_private_hosted_zone" {
  description = "Flag to enable or disable creation of private hosted zone"
  type        = bool
  default     = false
}
