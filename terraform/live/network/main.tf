################################################################################
# VPC
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = "${var.project}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.current.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_nat_gateway   = var.vpc_enable_nat_gateway
  single_nat_gateway   = var.vpc_single_nat_gateway
}

################################################################################
# ACM Certificate
################################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.1.0"

  domain_name = var.acm_domain_name

  subject_alternative_names = [
    "*.${var.acm_domain_name}"
  ]

  create_route53_records = true
}
