locals {
  common_tags = {
    Environment = var.environment
    Terraform   = true
    Project     = var.project
    Owner       = var.owner
  }
}
