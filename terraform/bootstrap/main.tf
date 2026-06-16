terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.44.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# KMS Key for encrypting Terraform State
resource "aws_kms_key" "state_key" {
  description             = "KMS key for encrypting Terraform state in S3"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "fleetops-terraform-state-key"
    Environment = "bootstrap"
  }
}

resource "aws_kms_alias" "state_key_alias" {
  name          = "alias/fleetops-terraform-state-key"
  target_key_id = aws_kms_key.state_key.key_id
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "state_bucket" {
  bucket        = var.state_bucket_name
  force_destroy = false # Prevent accidental deletion

  tags = {
    Name        = "fleetops-terraform-state"
    Environment = "bootstrap"
  }
}

# Versioning for State Bucket
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption for State Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Public Access Block for State Bucket
resource "aws_s3_bucket_public_access_block" "state_public_access" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Object Ownership Controls
resource "aws_s3_bucket_ownership_controls" "state_ownership" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 Bucket Policy to enforce TLS
resource "aws_s3_bucket_policy" "state_policy" {
  bucket = aws_s3_bucket.state_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# DynamoDB Lock Table
resource "aws_dynamodb_table" "lock_table" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "fleetops-terraform-locks"
    Environment = "bootstrap"
  }
}




