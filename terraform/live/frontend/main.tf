################################################################################
# S3
################################################################################
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.0.1"

  bucket        = "${var.project}-${var.environment}-fe"
  force_destroy = var.fe_bucket_force_destroy

  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  control_object_ownership = true                  #NOTE: see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  object_ownership         = "BucketOwnerEnforced" #NOTE: ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket

  versioning = {
    enabled = var.fe_bucket_enable_versioning
  }
}


resource "aws_s3_bucket_object" "index" {
  bucket       = module.s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = replace(file("${path.module}/resources/webapp/index.html"), "{{API_ENDPOINT}}", data.tfe_outputs.backend.values.api_endpoint)
  content_type = "text/html"
  etag         = filemd5("${path.module}/resources/webapp/index.html")
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

################################################################################
# CloudFront
# Create Certificate
################################################################################
module "acm" {
  count   = var.fe_domain_name == null ? 0 : 1
  source  = "terraform-aws-modules/acm/aws"
  version = "4.1.0"

  providers = {
    aws = aws.us-east-1
  }

  domain_name = var.fe_domain_name

  subject_alternative_names = [
    "*.${var.fe_domain_name}"
  ]

  create_route53_records = true
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "OAI ${var.environment} ${var.project}"
}

resource "aws_cloudfront_distribution" "this" {

  origin {
    domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.this.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.project
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "404"
    response_page_path = "/404"
  }


  aliases = var.fe_alias != null ? [var.fe_alias] : []

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.this.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.fe_min_ttl
    default_ttl            = var.fe_default_ttl
    max_ttl                = 86400
  }
  price_class = "PriceClass_100"

  dynamic "viewer_certificate" {
    for_each = var.fe_alias == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.fe_alias == null ? [] : [var.fe_alias]

    content {
      acm_certificate_arn      = module.acm.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }
}
