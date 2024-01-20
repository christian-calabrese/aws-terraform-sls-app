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
  timeout          = each.value.timeout
  publish          = true

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
# API Gateway V2
module "apigateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name        = "${var.project}-${var.environment}-notes-api"
  description = "API for CRUD operations on notes"

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.apigateway_logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  protocol_type = "HTTP"

  integrations = {
    for function in var.functions : "${function.http_method} ${function.path_part}" => {
      lambda_arn             = aws_lambda_function.functions[function.name].arn
      integration_type       = "AWS_PROXY"
      payload_format_version = "2.0"
    }
  }

  create_api_domain_name      = var.domain_name != null
  domain_name                 = var.domain_name != null ? "${var.subdomain_name}.${var.domain_name}" : null
  domain_name_certificate_arn = var.domain_name != null ? data.tfe_outputs.network.values.acm_certificate_arn : null
}

resource "aws_cloudwatch_log_group" "apigateway_logs" {
  name = "${var.project}-${var.environment}-notes-api-logs"
}

resource "aws_route53_record" "notes_api" {
  count = var.domain_name == null ? 0 : 1

  name    = var.subdomain_name
  type    = "A"
  zone_id = data.tfe_outputs.network.values.public_zone_id

  alias {
    name                   = module.apigateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.apigateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

################################################################################
# Additional resources
################################################################################
#The aws_codestarconnections_connection resource is created in the state PENDING.
#Authentication with the connection provider must be completed in the AWS Console.
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project}-${var.environment}-github-be"
  provider_type = "GitHub"
}
