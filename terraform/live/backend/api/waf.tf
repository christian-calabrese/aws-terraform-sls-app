# TODO: issue14 Integrate cloudfront + waf in front of HTTP api gateway 
################################################################################
# WAF Backend
################################################################################
# resource "aws_wafv2_web_acl" "this" {
#   name        = "${var.project}-${var.environment}-notes-api"
#   description = "Web ACL for ${var.project}-${var.environment}"
#   scope       = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "rateLimitRule"
#     priority = 0

#     action {
#       block {}
#     }

#     statement {
#       rate_based_statement {
#         limit              = var.waf_rate_based_statement_limit
#         aggregate_key_type = "IP"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project}-${var.environment}-metric-web-acl-rateLimitRule"
#       sampled_requests_enabled   = false
#     }
#   }

#   rule {
#     name     = "block_bot_control_requests"
#     priority = 1

#     override_action {
#       count {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesBotControlRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project}-${var.environment}-metric-web-acl-bot-control"
#       sampled_requests_enabled   = false
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "${var.project}-${var.environment}-metric-web-acl-general"
#     sampled_requests_enabled   = false
#   }
# }

# resource "aws_wafv2_web_acl_association" "this" {
#   provider     = aws.us-east-1
#   resource_arn = data.tfe_outputs.backend.values.api_stage_arn
#   web_acl_arn  = aws_wafv2_web_acl.this.arn
# }

# ################################################################################
# # WebAcl LogConfiguration
# ################################################################################
# resource "aws_cloudwatch_log_group" "web_acl_log_group" {
#   name              = "aws-waf-logs-${var.project}-api-gw-${var.environment}"
#   retention_in_days = var.waf_log_retention_days
# }

# resource "aws_wafv2_web_acl_logging_configuration" "web_acl_log_group_to_web_acl" {
#   log_destination_configs = [aws_cloudwatch_log_group.web_acl_log_group.arn]
#   resource_arn            = aws_wafv2_web_acl.this.arn
# }

# resource "aws_cloudwatch_log_resource_policy" "web_acl_log_group_policy" {
#   policy_document = data.aws_iam_policy_document.web_acl_log_group_policy.json
#   policy_name     = "${var.project}-${var.environment}-waf-logs-policy"
# }

# data "aws_iam_policy_document" "web_acl_log_group_policy" {
#   version = "2012-10-17"
#   statement {
#     effect = "Allow"
#     principals {
#       identifiers = ["delivery.logs.amazonaws.com"]
#       type        = "Service"
#     }
#     actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#     resources = ["${aws_cloudwatch_log_group.web_acl_log_group.arn}:*"]
#     condition {
#       test     = "ArnLike"
#       values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#       variable = "aws:SourceArn"
#     }
#     condition {
#       test     = "StringEquals"
#       values   = [tostring(data.aws_caller_identity.current.account_id)]
#       variable = "aws:SourceAccount"
#     }
#   }
# }
