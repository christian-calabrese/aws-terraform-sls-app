data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}

data "tfe_outputs" "backend" {
  organization = var.organization
  workspace    = "${var.project}-backend-${var.aws_region}-${var.environment}"
}
