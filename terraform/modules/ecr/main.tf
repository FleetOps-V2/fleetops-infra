# =============================================================
# Module: ecr  |  Phase: 2A
# 5 private repositories — one per FleetOps container image
# Includes lifecycle policy to keep only last 10 images
# =============================================================

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = { Project = var.project
    Environment = var.environment
    ManagedBy = "terraform"
    Module = "ecr" }

  repositories = [
    "auth-service",
    "vehicle-service",
    "request-service",
    "maintenance-service",
    "frontend"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.repositories)
  name                 = "${local.name_prefix}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}" })
}

# Lifecycle: keep last 10 tagged images, delete untagged after 1 day
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 1 day"
        selection    = { tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = 1 }
        action       = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only last 10 tagged images"
        selection    = {
      tagStatus = "tagged"
      tagPrefixList = ["v", "latest"]
      countType = "imageCountMoreThan"
      countNumber = 10
    }
        action       = { type = "expire" }
      }
    ]
  })
}





