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

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_notes.name
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/resources/lambdas"
  output_path = "${path.module}/backend.zip"
}

resource "aws_lambda_function" "create_note" {
  filename      = data.archive_file.lambda_code.output_path
  function_name = "${var.project}-${var.environment}-create-note"
  role          = aws_iam_role.lambda_notes.arn
  handler       = "create_note.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.notes.name
    }
  }
}

resource "aws_lambda_function" "get_note" {
  filename      = data.archive_file.lambda_code.output_path
  function_name = "${var.project}-${var.environment}-get-note"
  role          = aws_iam_role.lambda_notes.arn
  handler       = "get_note.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.notes.name
    }
  }
}

resource "aws_lambda_function" "delete_note" {
  filename      = data.archive_file.lambda_code.output_path
  function_name = "${var.project}-${var.environment}-delete-note"
  role          = aws_iam_role.lambda_notes.arn
  handler       = "delete_note.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.notes.name
    }
  }
}

################################################################################
# API Gateway
################################################################################

resource "aws_apigateway_rest_api" "notes_api" {
  name        = "${var.project}-${var.environment}-notes-api"
  description = "API for CRUD operations on notes"
}

resource "aws_apigateway_resource" "notes_resource" {
  rest_api_id = aws_apigateway_rest_api.notes_api.id
  parent_id   = aws_apigateway_rest_api.notes_api.root_resource_id
  path_part   = "notes"
}

resource "aws_apigateway_resource" "note_resource" {
  rest_api_id = aws_apigateway_rest_api.notes_api.id
  parent_id   = aws_apigateway_resource.notes_resource.id
  path_part   = "{note_id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_note.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigateway_rest_api.notes_api.execution_arn}/*/*/notes/${aws_apigateway_resource.note_resource.path_part}"
}

resource "aws_apigateway_method" "create_note" {
  rest_api_id   = aws_apigateway_rest_api.notes_api.id
  resource_id   = aws_apigateway_resource.notes_resource.id
  http_method   = "POST"
  authorization = "NONE"

  integration {
    type = "AWS_PROXY"
    uri  = aws_lambda_function.create_note.invoke_arn
  }
}

resource "aws_apigateway_method" "get_note" {
  rest_api_id   = aws_apigateway_rest_api.notes_api.id
  resource_id   = aws_apigateway_resource.note_resource.id
  http_method   = "GET"
  authorization = "NONE"

  integration {
    type = "AWS_PROXY"
    uri  = aws_lambda_function.get_note.invoke_arn
  }
}

resource "aws_apigateway_method" "delete_note" {
  rest_api_id   = aws_apigateway_rest_api.notes_api.id
  resource_id   = aws_apigateway_resource.note_resource.id
  http_method   = "DELETE"
  authorization = "NONE"

  integration {
    type = "AWS_PROXY"
    uri  = aws_lambda_function.delete_note.invoke_arn
  }
}

resource "aws_api_gateway_deployment" "notes_api" {
  rest_api_id = aws_apigateway_rest_api.notes_api.id

  depends_on = [aws_lambda_permission.apigw, aws_apigateway_method.create_note, aws_apigateway_method.get_note, aws_apigateway_method.delete_note, ]
}
