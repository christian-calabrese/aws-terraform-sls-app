################################################################################
# WAF Frontend
################################################################################
resource "aws_wafv2_web_acl" "fe" {
  provider    = aws.us-east-1
  name        = "${var.project}-${var.environment}-notes-frontend"
  description = "Web ACL for ${var.project}-${var.environment} frontend"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rateLimitRule"
    priority = 0

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_based_statement_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-${var.environment}-metric-web-acl-frontend-rateLimitRule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "block_bot_control_requests"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-${var.environment}-metric-web-acl-frontend-bot-control"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.project}-${var.environment}-metric-web-acl-frontend-general"
    sampled_requests_enabled   = false
  }
}

################################################################################
# WebAcl LogConfiguration
################################################################################
resource "aws_cloudwatch_log_group" "web_acl_log_group_fe" {
  provider          = aws.us-east-1
  name              = "aws-waf-logs-${var.project}-fe-${var.environment}"
  retention_in_days = var.waf_log_retention_days
}

resource "aws_wafv2_web_acl_logging_configuration" "web_acl_log_group_to_web_acl_fe" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.web_acl_log_group_fe.arn]
  resource_arn            = aws_wafv2_web_acl.fe.arn
}

resource "aws_cloudwatch_log_resource_policy" "web_acl_log_group_fe_policy" {
  provider        = aws.us-east-1
  policy_document = data.aws_iam_policy_document.web_acl_log_group_policy_fe.json
  policy_name     = "${var.project}-${var.environment}-waf-logs-policy"
}

data "aws_iam_policy_document" "web_acl_log_group_policy_fe" {
  provider = aws.us-east-1
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.web_acl_log_group_fe.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}
