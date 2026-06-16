# =============================================================
# Module: eks/addons  |  Phase: 2B
# Installs Helm-based add-ons into the EKS cluster:
#   1. AWS Load Balancer Controller   — creates ALBs from Ingress
#   2. External Secrets Operator      — syncs Secrets Manager → k8s Secrets
#   3. Metrics Server                 — kubectl top, HPA
#   4. Cluster Autoscaler             — adds/removes t3.small nodes
#
# Provider note: helm and kubernetes providers are configured
# dynamically from the cluster outputs — see versions.tf
# =============================================================

locals {
  name_prefix  = "${var.project}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"
  common_tags  = {
    Project = var.project
    Environment = var.environment
    ManagedBy = "terraform"
    Module = "eks/addons"
  }
}

# ── IRSA Role for AWS Load Balancer Controller ────────────────
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "alb_controller" {
  name = "${local.name_prefix}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${local.name_prefix}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  # Full policy from AWS docs (abbreviated here — use the official JSON in production)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:*", "ec2:Describe*", "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:RevokeSecurityGroupIngress", "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
                    "ec2:CreateTags", "ec2:DeleteTags", "ec2:ModifyNetworkInterfaceAttribute",
                    "cognito-idp:DescribeUserPoolClient", "acm:ListCertificates",
                    "acm:DescribeCertificate", "iam:CreateServiceLinkedRole",
                    "shield:GetSubscriptionState", "wafv2:*", "waf-regional:*", "tag:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# ── IRSA Role for Cluster Autoscaler ─────────────────────────
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${local.name_prefix}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "${local.name_prefix}-cluster-autoscaler-policy"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeInstanceTypes",
        "eks:DescribeNodegroup"
      ]
      Resource = "*"
    }]
  })
}

# ── IRSA Role for External Secrets Operator ───────────────────
resource "aws_iam_role" "external_secrets" {
  name = "${local.name_prefix}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "external_secrets" {
  name = "${local.name_prefix}-external-secrets-policy"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project}/*"
    }]
  })
}

# ── Helm: AWS Load Balancer Controller ───────────────────────
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name = "clusterName"
    value = var.cluster_name
  }
  set {
    name = "serviceAccount.create"
    value = "true"
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }
  set {
    name = "region"
    value = var.aws_region
  }
  set {
    name = "vpcId"
    value = var.vpc_id
  }
}

# ── Helm: External Secrets Operator ──────────────────────────
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "external-secrets"
  version    = "0.9.19"

  create_namespace = true

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }
}

# ── Helm: Metrics Server ──────────────────────────────────────
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
}

# ── Helm: Cluster Autoscaler ──────────────────────────────────
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name = "awsRegion"
    value = var.aws_region
  }
  set {
    name = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }
  set {
    name = "extraArgs.balance-similar-node-groups"
    value = "true"
  }
  set {
    name = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }
}

# -- Helm: ArgoCD (GitOps) ---------------------------------------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.7.11"

  # Automatically bootstrap the Root Application!
  values = [
    yamlencode({
      server = {
        additionalApplications = [
          {
            name      = "fleetops-root-prod"
            namespace = "argocd"
            project   = "default"
            source = {
              repoURL        = "https://github.com/FleetOps-Project-Devops/fleetops-deployments.git"
              targetRevision = "HEAD"
              path           = "argocd/apps/prod"
            }
            destination = {
              server    = "https://kubernetes.default.svc"
              namespace = "argocd"
            }
            syncPolicy = {
              automated = {
                prune    = true
                selfHeal = true
              }
              syncOptions = ["CreateNamespace=true"]
            }
          }
        ]
      }
    })
  ]
}

# -- EKS Managed Add-on: Amazon CloudWatch Observability ---------------------
# Installs CloudWatch Agent + Container Insights so that pod-level CPU,
# memory, and network metrics flow into CloudWatch.
# Without this addon, "Pods --> Metrics --> CloudWatch" does NOT work.
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = var.cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  addon_version            = "v1.7.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.cloudwatch_agent.arn
  tags                     = local.common_tags
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${local.name_prefix}-cloudwatch-agent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# -- EKS Managed Add-on: Fluent Bit (Container Log Shipping) ----------------
# Forwards all container stdout/stderr logs from every pod to CloudWatch Logs.
# Without this addon, no application logs are visible in CloudWatch.
resource "aws_eks_addon" "fluent_bit" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-for-fluent-bit"
  service_account_role_arn = aws_iam_role.fluent_bit.arn
  tags                     = local.common_tags
}

resource "aws_iam_role" "fluent_bit" {
  name = "${local.name_prefix}-fluent-bit-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:amazon-cloudwatch:fluent-bit"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "fluent_bit_logs" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}




