# AWS DevOps Agent Setup — FleetOps

AWS DevOps Agent is an always-on, autonomous incident response service that monitors FleetOps infrastructure via Capability Providers (CloudWatch, EKS, RDS). No Lambda or EventBridge required — AWS manages the agent lifecycle.

## IAM Role (Terraform-provisioned)

The role is already created by `terraform apply`:

```bash
terraform output devops_agent_role_arn
# Example: arn:aws:iam::538661800892:role/fleetops-dev-devops-agent-role
```

Policies attached:
- `CloudWatchReadOnlyAccess` — EKS/RDS/ALB metrics and alarms
- `AmazonEKSClusterPolicy` — cluster health and pod status
- `AmazonRDSReadOnlyAccess` — database health

## Console Setup

Open: `https://us-east-1.console.aws.amazon.com/aidevops`

### 1. Create Agent Space

| Field | Value |
|---|---|
| Name | `fleetops-dev-devops-space` |
| Description | Autonomous DevOps AI for FleetOps EKS infrastructure |
| IAM Role ARN | output of `terraform output devops_agent_role_arn` |

### 2. Add Capability Providers

| Provider | Configuration |
|---|---|
| Amazon CloudWatch | Account 538661800892, region us-east-1. Select alarms: EKS CPU, RDS connections, ALB 5XX |
| Amazon EKS | Cluster: fleetops-dev-eks-cluster |
| Amazon RDS | Select FleetOps RDS instance identifier |

### 3. Enable Agent

Click Enable — agent is now always-on, continuously monitoring FleetOps infrastructure.

## Agent Space Details (fill after setup)

```
Agent Space ID:       <from console after creation>
Agent Space Name:     fleetops-dev-devops-space
Role ARN:             <terraform output devops_agent_role_arn>
Region:               us-east-1
Capability Providers: CloudWatch, EKS, RDS
EKS Cluster:          fleetops-dev-eks-cluster
Status:               Active
```

## What the Agent Does

- Detects anomalies in CloudWatch metrics (EKS CPU spikes, RDS connection exhaustion, ALB 5XX surges)
- Investigates root cause autonomously across the Capability Providers
- Recommends or performs remediation actions
- Sends SNS notifications on significant findings

This is the native AWS DevOps Agent managed service — not a custom Bedrock Agent or Lambda workaround.
