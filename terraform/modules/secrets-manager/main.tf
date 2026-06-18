# =============================================================
# Module: secrets-manager  |  Phase: 2A
# Provisions credential templates for DB + JWT
# Actual values are injected via Terraform variables (from tfvars
# or CI/CD pipeline env vars) — never hardcoded
# =============================================================

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "secrets-manager"
  }
}

# ── Database Master Credentials ───────────────────────────────
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project}/${var.environment}/db"
  description             = "FleetOps RDS PostgreSQL master credentials"
  kms_key_id              = var.kms_secrets_key_arn
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    host     = var.db_host
    port     = 5432
    dbname   = "postgres"
    username = var.db_username
    password = var.db_password
  })
}

# ── JWT Signing Secret ────────────────────────────────────────
resource "aws_secretsmanager_secret" "jwt" {
  name                    = "${var.project}/${var.environment}/jwt"
  description             = "FleetOps JWT signing secret (min 32 chars)"
  kms_key_id              = var.kms_secrets_key_arn
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-jwt-secret" })
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = jsonencode({ jwt_secret = var.jwt_secret })
}

# ── GitHub PAT for ArgoCD ─────────────────────────────────────
# ArgoCD uses this to pull from the private fleetops-deployments repo.
# recovery_window_in_days = 0 for dev so destroy + apply works immediately.
resource "aws_secretsmanager_secret" "github_pat" {
  name                    = "${var.project}/${var.environment}/github-pat"
  description             = "GitHub PAT for ArgoCD to pull fleetops-deployments"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-github-pat" })
}

resource "aws_secretsmanager_secret_version" "github_pat" {
  secret_id     = aws_secretsmanager_secret.github_pat.id
  secret_string = jsonencode({
    username = var.github_username
    token    = var.github_pat
  })
}




