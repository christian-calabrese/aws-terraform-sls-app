################################################################################
# Backend
################################################################################
output "api_endpoint" {
  description = "The endpoint of the REST API"
  value       = aws_api_gateway_stage.notes_api.invoke_url
}

output "api_stage_arn" {
  description = "The arn of the REST API stage"
  value       = aws_api_gateway_stage.notes_api.arn
}

output "aws_codestarconnections_connection_github_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "functions_arn" {
  description = "Dictionary of arns (value) and function names (key)"
  value       = { for k, v in aws_lambda_function.functions : k => v.arn }
}