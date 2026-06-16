# =============================================================
# Module: rds  |  Phase: 2A
# db.t3.micro PostgreSQL — Free Tier, Single-AZ, KMS-encrypted
# =============================================================

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = { Project = var.project
    Environment = var.environment
    ManagedBy = "terraform"
    Module = "rds" }
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier              = "${local.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted       = true
  kms_key_id              = var.kms_rds_key_arn

  db_name                 = "postgres"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.rds_sg_id]

  multi_az                = false   # Single-AZ — Free Tier
  publicly_accessible     = false
  deletion_protection     = var.enable_deletion_protection
  skip_final_snapshot     = !var.enable_deletion_protection
  final_snapshot_identifier = var.enable_deletion_protection ? "${local.name_prefix}-final-snapshot" : null

  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-postgres" })
}




