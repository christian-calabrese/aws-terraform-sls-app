################################################################################
# Backend
################################################################################
output "api_endpoint" {
  description = "The endpoint of the REST API"
  value       = aws_api_gateway_stage.notes_api.invoke_url
}
