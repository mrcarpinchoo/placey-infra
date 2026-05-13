variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR block for the private app subnet (AZ-a)"
  type        = string
}

variable "data_subnet_cidr_a" {
  description = "CIDR block for the private data subnet (AZ-a)"
  type        = string
}

variable "data_subnet_cidr_b" {
  description = "CIDR block for the private data subnet (AZ-b)"
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
  description = "Tags to apply to RDS instances, Lambda functions, and S3 buckets"
  type        = map(string)
}
