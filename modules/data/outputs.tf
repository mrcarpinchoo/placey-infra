output "rds_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "rds_proxy_arn" {
  description = "ARN of the RDS Proxy"
  value       = aws_db_proxy.main.arn
}

output "rds_proxy_endpoint" {
  description = "Endpoint of the RDS Proxy"
  value       = aws_db_proxy.main.endpoint
}
