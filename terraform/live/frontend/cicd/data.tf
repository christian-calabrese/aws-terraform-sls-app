data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}

data "tfe_outputs" "frontend" {
  organization = var.organization
  workspace    = "${var.project}-frontend-${var.aws_region}-${var.environment}"
}
