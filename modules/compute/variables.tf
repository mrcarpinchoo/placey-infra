variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_subnet_id" {
  description = "ID of the private app subnet"
  type        = string
}

variable "lambda_sg_id" {
  description = "ID of the Lambda security group"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret"
  type        = string
}

variable "rds_proxy_endpoint" {
  description = "Endpoint of the RDS Proxy"
  type        = string
}

variable "tags" {
  description = "Tags to apply to Lambda functions"
  type        = map(string)
}
