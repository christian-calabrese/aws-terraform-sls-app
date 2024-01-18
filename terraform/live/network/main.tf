################################################################################
# VPC
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

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
# Route53
################################################################################
resource "aws_route53_zone" "public_zone" {
  count   = var.domain_name == null ? 0 : 1
  name    = var.environment == "prod" ? var.domain_name : "${var.environment}.${var.domain_name}"
  comment = "Public zone of the domain"
}

resource "aws_route53_zone" "private_zone" {
  count   = var.create_private_hosted_zone ? 1 : 0
  name    = var.domain_name
  comment = "Private zone for vpc internal resolution"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  # Prevent the deletion of associated VPCs after
  # the initial creation. See documentation on
  # aws_route53_zone_association for details
  lifecycle {
    ignore_changes = [vpc]
  }
}

################################################################################
# ACM
################################################################################
module "acm" {
  count   = var.domain_name == null ? 0 : 1
  source  = "terraform-aws-modules/acm/aws"
  version = "4.1.0"

  domain_name = var.domain_name

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  create_route53_records = true
}
