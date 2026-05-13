variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "data_subnet_ids" {
  description = "IDs of the private data subnets"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "rds_proxy_sg_id" {
  description = "ID of the RDS Proxy security group"
  type        = string
}

variable "rds_proxy_role_arn" {
  description = "ARN of the RDS Proxy IAM role"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "tags" {
  description = "Tags to apply to RDS resources"
  type        = map(string)
}
