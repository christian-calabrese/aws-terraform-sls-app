################################################################################
# DynamoDB
################################################################################
resource "aws_dynamodb_table" "notes" {
  name         = "${var.project}-${var.environment}-notes"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "note_id"
    type = "S"
  }

  hash_key = "note_id"
}

################################################################################
# Lambda
################################################################################
resource "aws_iam_role" "lambda_notes" {
  name = "${var.project}-${var.environment}-notes-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "LambdaDynamoDBPolicy"
  description = "Policy to allow Lambda function to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.notes.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_notes.name
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_notes.name
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/resources/lambdas"
  output_path = "${path.module}/backend.zip"
}

resource "aws_lambda_function" "functions" {
  for_each         = { for i, f in var.functions : f.name => f }
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  function_name    = "${var.project}-${var.environment}-${each.value.name}"
  role             = aws_iam_role.lambda_notes.arn
  handler          = each.value.handler
  runtime          = each.value.runtime

  environment {
    variables = merge({
      DYNAMODB_TABLE = aws_dynamodb_table.notes.name
    }, each.value.environment)
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}

################################################################################
# API Gateway
################################################################################
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.main.arn
}

resource "aws_iam_role" "main" {
  name = "api-gateway-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_method_settings" "notes_api" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id
  stage_name  = aws_api_gateway_stage.notes_api.stage_name
  method_path = "*/*"
  settings {
    logging_level = "ERROR"
  }

  depends_on = [aws_api_gateway_account.main]
}

resource "aws_api_gateway_rest_api" "notes_api" {
  name        = "${var.project}-${var.environment}-notes-api"
  description = "API for CRUD operations on notes"
}

resource "aws_api_gateway_resource" "notes_resource" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id
  parent_id   = aws_api_gateway_rest_api.notes_api.root_resource_id
  path_part   = "notes"
}

resource "aws_api_gateway_resource" "note_resource" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id
  parent_id   = aws_api_gateway_resource.notes_resource.id
  path_part   = "{note_id}"
}

resource "aws_api_gateway_method" "functions" {
  for_each       = { for i, f in var.functions : f.name => f }
  rest_api_id    = aws_api_gateway_rest_api.notes_api.id
  resource_id    = aws_api_gateway_resource.notes_resource.id
  http_method    = each.value.http_method
  authorization  = "NONE"
  operation_name = "${each.value.name}-operation"
}

resource "aws_api_gateway_integration" "functions" {
  for_each                = { for i, f in var.functions : f.name => f }
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.notes_resource.id
  http_method             = each.value.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.functions[each.key].invoke_arn

  depends_on = [
    aws_lambda_permission.functions[each.key]
  ]
}

resource "aws_lambda_permission" "functions" {
  for_each      = { for i, f in var.functions : f.name => f }
  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notes_api.execution_arn}/*/${each.value.http_method}${each.value.path_part}"
}

resource "aws_api_gateway_deployment" "notes_api" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.notes_api.body))
  }

  depends_on = [aws_lambda_permission.create_note, aws_lambda_permission.get_notes, aws_lambda_permission.get_note, aws_lambda_permission.delete_note, aws_api_gateway_method.create_note, aws_api_gateway_method.get_notes, aws_api_gateway_method.get_note, aws_api_gateway_method.delete_note]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "notes_api" {
  deployment_id = aws_api_gateway_deployment.notes_api.id
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  stage_name    = var.environment

  depends_on = [aws_cloudwatch_log_group.api_gateway]
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.notes_api.id}/${var.environment}"
  retention_in_days = 7
}

module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.notes_api.id
  api_resource_id = aws_api_gateway_resource.note_resource.id
}

################################################################################
# API Gateway Custom Domain
################################################################################

resource "aws_api_gateway_domain_name" "notes_api" {
  count = var.domain_name == null ? 0 : 1

  domain_name     = var.domain_name
  certificate_arn = data.tfe_outputs.network.values.acm_certificate_arn

  endpoint_configuration {
    types = [var.api_gateway_scope]
  }
}

resource "aws_api_gateway_base_path_mapping" "notes_api" {
  count = var.domain_name == null ? 0 : 1

  api_id      = aws_api_gateway_rest_api.notes_api.id
  stage_name  = aws_api_gateway_stage.notes_api.stage_name
  domain_name = aws_api_gateway_domain_name.notes_api.id

}

resource "aws_route53_record" "notes_api" {
  count = var.domain_name == null ? 0 : 1

  name    = aws_api_gateway_domain_name.notes_api.domain_name
  type    = "A"
  zone_id = data.tfe_outputs.network.values.public_zone_id

  alias {
    evaluate_target_health = true
    name                   = var.api_gateway_scope == "REGIONAL" ? aws_api_gateway_domain_name.notes_api.regional_domain_name : aws_api_gateway_domain_name.notes_api.cloudfront_domain_name
    zone_id                = var.api_gateway_scope == "REGIONAL" ? aws_api_gateway_domain_name.notes_api.regional_zone_id : aws_api_gateway_domain_name.notes_api.cloudfront_zone_id
  }
}

################################################################################
# Additional resources
################################################################################
#The aws_codestarconnections_connection resource is created in the state PENDING.
#Authentication with the connection provider must be completed in the AWS Console.
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project}-${var.environment}-github-codestar-connection-frontend"
  provider_type = "GitHub"
}
