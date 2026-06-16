# =============================================================
# Module: ssm  |  Phase: 2A
# Non-sensitive configuration parameters (endpoints, config values)
# Sensitive values go to Secrets Manager — SSM holds public config
# =============================================================

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project = var.project
    Environment = var.environment
    ManagedBy = "terraform"
    Module = "ssm"
  }
}

resource "aws_ssm_parameter" "redis_endpoint" {
  name        = "/${var.project}/${var.environment}/redis/endpoint"
  description = "ElastiCache Redis primary endpoint"
  type        = "String"
  value       = var.redis_endpoint
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "cors_allowed_origins" {
  name        = "/${var.project}/${var.environment}/app/cors-origins"
  description = "CORS allowed origins for the API gateway"
  type        = "String"
  value       = var.cors_allowed_origins
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "spring_profile" {
  name        = "/${var.project}/${var.environment}/app/spring-profile"
  description = "Active Spring Boot profile"
  type        = "String"
  value       = var.environment == "prod" ? "prod" : "dev"
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "app_base_url" {
  name        = "/${var.project}/${var.environment}/app/base-url"
  description = "Public base URL of the FleetOps application"
  type        = "String"
  value       = var.app_base_url
  tags        = local.common_tags
}




