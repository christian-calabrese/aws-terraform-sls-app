################################################################################
# Frontend
################################################################################
output "fe_s3_bucket_name" {
  description = "The name of the bucket containing the frontend webapp"
  value       = module.s3_bucket.s3_bucket_id
}

output "fe_s3_bucket_arn" {
  description = "The arn of the bucket containing the frontend webapp"
  value       = module.s3_bucket.s3_bucket_arn
}

output "fe_cloudfront_distribution_id" {
  description = "The id of the cloudfront distribution publishing the frontend webapp"
  value       = aws_cloudfront_distribution.this.id
}

output "fe_cloudfront_distribution_arn" {
  description = "The arn of the cloudfront distribution publishing the frontend webapp"
  value       = aws_cloudfront_distribution.this.arn
}

output "aws_codestarconnections_connection_github_arn" {
  value = aws_codestarconnections_connection.github.arn
}
