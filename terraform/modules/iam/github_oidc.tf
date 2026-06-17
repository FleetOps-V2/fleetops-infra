# =============================================================
# GitHub Actions OIDC Federation
# Allows GitHub Actions workflows to assume an AWS IAM role
# using a short-lived OIDC token — no long-lived access keys.
#
# Trust scope: restricted to the fleetops-infra repository only.
# Any branch or workflow_dispatch trigger is permitted within
# that repo; no other GitHub org or repo can assume this role.
# =============================================================

# GitHub's OIDC provider — one per AWS account, shared across repos
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint — stable; rotated by GitHub if their root CA changes
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(local.common_tags, { Name = "github-actions-oidc-provider" })
}

# IAM Role assumed by GitHub Actions via OIDC token
resource "aws_iam_role" "github_actions" {
  name = "${local.name_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Restricts to this repo only — no other GitHub org/repo can assume the role
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })

  tags = local.common_tags
}

# Terraform requires broad permissions to provision all FleetOps infrastructure.
# AdministratorAccess is used here for the training environment.
# Production recommendation: replace with a PermissionsBoundary or
# service-specific policies scoped to the resources Terraform manages.
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
