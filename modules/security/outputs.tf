output "lambda_sg_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda.id
}

output "rds_proxy_sg_id" {
  description = "ID of the RDS Proxy security group"
  value       = aws_security_group.rds_proxy.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_id" {
  description = "ID of the Lambda execution role"
  value       = aws_iam_role.lambda.id
}

output "rds_proxy_role_arn" {
  description = "ARN of the RDS Proxy IAM role"
  value       = aws_iam_role.rds_proxy.arn
}

output "rds_proxy_role_id" {
  description = "ID of the RDS Proxy IAM role"
  value       = aws_iam_role.rds_proxy.id
}
