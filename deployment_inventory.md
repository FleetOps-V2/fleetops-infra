# FleetOps V2 Deployment Inventory

This document maps FleetOps capabilities to specific AWS resources, serving as the project verification and architecture validation log.

## Service Mapping Table

| Feature Area | Microservice | Local Component | AWS Target Resource | Terraform Module | Status |
|---|---|---|---|---|---|
| **Identity & Access** | `auth-service` | PostgreSQL DB, JWT | Amazon RDS (PostgreSQL), Secrets Manager, KMS, IAM Roles | `modules/security` | Pending |
| **Vehicle Fleet Mgmt** | `vehicle-service` | PostgreSQL DB, Redis | Amazon RDS (PostgreSQL), Amazon ElastiCache (Redis), Secrets Manager, KMS | `modules/security` | Pending |
| **Service Requests** | `request-service` | PostgreSQL DB | Amazon RDS (PostgreSQL), Secrets Manager, KMS | `modules/security` | Pending |
| **Maintenance Queue** | `maintenance-service` | PostgreSQL DB | Amazon RDS (PostgreSQL), Secrets Manager, KMS | `modules/security` | Pending |
| **API Routing / Proxy** | `gateway` | Nginx (Reverse Proxy) | Application Load Balancer (ALB) | N/A (Phase 4) | Pending |
| **User Interface** | `frontend` | React SPA + Vite | Amazon S3 (Static Web Hosting) + CloudFront CDN | N/A (Phase 4) | Pending |
| **Infrastructure State** | Platform | Local State File | Amazon S3 State Bucket + DynamoDB Lock Table | `bootstrap` | Pending |

---

## AWS Security & Configuration Inventory

### 1. Key Management Service (KMS)
Separate Customer Managed Keys (CMKs) are configured to satisfy security audit isolation requirements:

*   **`fleetops-terraform-state-key`**: Encrypts the remote state file within the S3 bootstrap bucket.
*   **`fleetops-s3-documents-key`**: Encrypts user-uploaded documents (e.g. maintenance records, telemetry logs).
*   **`fleetops-database-key`**: Encrypts RDS Postgres tablespaces and automatic snapshots.
*   **`fleetops-secrets-key`**: Encrypts sensitive environment configs inside Secrets Manager and SSM Parameters.

### 2. IAM Roles
No access keys are defined. Application containers utilize AWS role-based security:

*   **`FleetOpsEC2Role`**: Used by the EC2 instances in the staging environment. Encapsulates SSM systems manager core access.
*   **`FleetOpsECSExecutionRole`**: Allows ECS agent to pull Docker images from ECR and send container stdout to CloudWatch Logs.
*   **`FleetOpsECSTaskRole`**: Restricts active microservice runtimes, granting narrow permissions to decrypt keys and fetch credentials.
*   **`FleetOpsLambdaRole`**: Enables execution and logging of auxiliary processing tasks.

### 3. Application Configuration (Secrets & Parameters)
Variables are decoupled from source repositories using KMS-encrypted systems:

*   **Secrets Manager (`fleetops/{env}/database/credentials`)**: Holds PostgreSQL dynamic admin credentials.
*   **Secrets Manager (`fleetops/{env}/auth/jwt-secret`)**: Stores the JWT private key.
*   **SSM Parameter (`/fleetops/{env}/redis/endpoint`)**: Stores the Redis hostname.
*   **SSM Parameter (`/fleetops/{env}/cors/origins`)**: Manages the CORS whitelist configurations.
