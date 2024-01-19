data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}

data "tfe_outputs" "network" {
  organization = var.organization
  workspace    = "${var.project}-network-${var.aws_region}-${var.environment}"
}
