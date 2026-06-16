output "vpc_id"                   { value = module.networking.vpc_id }
output "private_subnet_ids"       { value = module.networking.private_subnet_ids }
output "public_subnet_ids"        { value = module.networking.public_subnet_ids }
output "ecr_repository_urls"      { value = module.ecr.repository_urls }
output "rds_endpoint"             { value = module.rds.db_endpoint }
output "redis_endpoint"           { value = module.redis.redis_endpoint }
output "s3_vehicle_docs_bucket"   { value = module.s3.vehicle_docs_bucket_name }
output "efs_id"                   { value = module.efs.efs_id }
output "efs_dns_name"             { value = module.efs.efs_dns_name }
output "db_secret_arn"            { value = module.secrets_manager.db_secret_arn }
output "jwt_secret_arn"           { value = module.secrets_manager.jwt_secret_arn }
output "route53_name_servers"     { value = module.route53.name_servers }
output "eks_node_role_arn"        { value = module.iam.eks_node_role_arn }
output "app_irsa_role_arn"        { value = module.iam.app_irsa_role_arn }

output "kms_rds_key_arn"          { value = module.kms.rds_key_arn }
output "kms_secrets_key_arn"      { value = module.kms.secrets_key_arn }
output "kms_s3_key_arn"           { value = module.kms.s3_key_arn }




