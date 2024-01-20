################################################################################
# Lambda
################################################################################
resource "aws_iam_role" "lambda_invalidation" {
  name = "${var.project}-${var.environment}-invalidation-lambda-role"

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

resource "aws_iam_policy" "lambda_cloudfront_policy" {
  name        = "LambdacloudfrontPolicy"
  description = "Policy to allow Lambda function to access cloudfront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution"
        ]
        Effect   = "Allow"
        Resource = data.tfe_outputs.frontend.values.fe_cloudfront_distribution_arn
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${data.tfe_outputs.frontend.values.fe_s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  policy_arn = aws_iam_policy.lambda_cloudfront_policy.arn
  role       = aws_iam_role.lambda_invalidation.name
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_invalidation.name
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/resources/invalidate_cache_lambda"
  output_path = "${path.module}/backend.zip"
}

resource "aws_lambda_function" "create_invalidation" {
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  function_name    = "${var.project}-${var.environment}-invalidate-cache-lambda"
  role             = aws_iam_role.lambda_invalidation.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = data.tfe_outputs.frontend.values.fe_cloudfront_distribution_id
      FE_BUCKET_NAME             = data.tfe_outputs.frontend.values.fe_s3_bucket_name
      API_ENDPOINT               = data.tfe_outputs.backend.values.api_endpoint
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}
