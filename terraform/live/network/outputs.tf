################################################################################
# VPC
################################################################################
output "vpc_id" {
  description = "The ID of VPC"
  value       = module.vpc.vpc_id
}

output "vpc_azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = module.vpc.azs
}

output "vpc_cidr" {
  description = "The CIDR of the VPC"
  value       = var.vpc_cidr
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

################################################################################
# Route53
################################################################################
output "public_zone_id" {
  description = "The public hosted zone id"
  value       = var.domain_name != null ? aws_route53_zone.public_zone.id : null
}

output "public_zone_arn" {
  description = "The public hosted zone arn"
  value       = var.domain_name != null ? aws_route53_zone.public_zone.arn : null
}

output "private_zone_id" {
  description = "The private hosted zone id"
  value       = aws_route53_zone.private_zone.id
}

output "private_zone_arn" {
  description = "The private hosted zone arn"
  value       = aws_route53_zone.private_zone.arn
}

output "acm_certificate_arn" {
  description = "The arn of the certificate"
  value       = var.domain_name != null ? module.acm.acm_certificate_arn : null
}
