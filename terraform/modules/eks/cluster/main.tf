# =============================================================
# Module: eks/cluster  |  Phase: 2B
# Provisions the EKS Control Plane
# =============================================================

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"
  common_tags  = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "eks/cluster"
  }
}

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  version  = var.eks_cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    security_group_ids      = [var.control_plane_sg_id]
    endpoint_public_access  = true   # kubectl access from outside
    endpoint_private_access = true   # node-to-API internal access
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  tags = merge(local.common_tags, { Name = local.cluster_name })

  depends_on = [var.eks_cluster_role_arn]
}

# ── EKS Cluster IAM Role ──────────────────────────────────────
resource "aws_iam_role" "eks_cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}




