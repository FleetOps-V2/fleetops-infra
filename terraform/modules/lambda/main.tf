locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "lambda"
  }
}

data "archive_file" "dummy_lambda" {
  type        = "zip"
  source_file = "${path.module}/src/index.js"
  output_path = "${path.module}/src/lambda_function_payload.zip"
}

# 1. Alert Processor Lambda
resource "aws_lambda_function" "alert_processor" {
  filename         = data.archive_file.dummy_lambda.output_path
  function_name    = "${local.name_prefix}-alert-processor"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256
  runtime          = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = local.common_tags
}

# 2. Document Metadata Extractor Lambda
resource "aws_lambda_function" "metadata_extractor" {
  filename         = data.archive_file.dummy_lambda.output_path
  function_name    = "${local.name_prefix}-metadata-extractor"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256
  runtime          = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = local.common_tags
}




