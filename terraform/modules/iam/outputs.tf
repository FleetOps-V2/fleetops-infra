output "eks_node_role_arn"           { value = aws_iam_role.eks_node.arn }
output "eks_node_instance_profile"   { value = aws_iam_instance_profile.eks_node.name }
output "app_irsa_role_arn"           { value = aws_iam_role.app_service_account.arn }
output "lambda_role_arn"             { value = aws_iam_role.lambda.arn }




