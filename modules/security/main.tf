data "aws_region" "current" {}

# Security Groups

resource "aws_security_group" "lambda" {
  name        = "placey-${var.environment}-sg-lambda"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-sg-lambda"
  })
}

resource "aws_security_group" "rds_proxy" {
  name        = "placey-${var.environment}-sg-rds-proxy"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-sg-rds-proxy"
  })
}

resource "aws_security_group" "rds" {
  name        = "placey-${var.environment}-sg-rds"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-sg-rds"
  })
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "placey-${var.environment}-sg-vpc-endpoint"
  description = "Security group for Secrets Manager VPC Endpoint"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-sg-vpc-endpoint"
  })
}

# Security Group Rules

resource "aws_vpc_security_group_egress_rule" "lambda_to_rds_proxy" {
  security_group_id            = aws_security_group.lambda.id
  description                  = "Lambda to RDS Proxy"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds_proxy.id
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_vpc_endpoint" {
  security_group_id            = aws_security_group.lambda.id
  description                  = "Lambda to Secrets Manager"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.vpc_endpoint.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_proxy_from_lambda" {
  security_group_id            = aws_security_group.rds_proxy.id
  description                  = "PostgreSQL from Lambda"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lambda.id
}

resource "aws_vpc_security_group_egress_rule" "rds_proxy_to_rds" {
  security_group_id            = aws_security_group.rds_proxy.id
  description                  = "RDS Proxy to RDS"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_rds_proxy" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL from RDS Proxy"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.rds_proxy.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_maintenance" {
  security_group_id = aws_security_group.rds.id
  description       = "Maintenance access — change source to My IP when needed, revert when done"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/32"
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_from_lambda" {
  security_group_id            = aws_security_group.vpc_endpoint.id
  description                  = "HTTPS from Lambda"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lambda.id
}

# VPC Endpoint for Secrets Manager

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.app_subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-vpce-secretsmanager"
  })
}

# IAM Role: Lambda

resource "aws_iam_role" "lambda" {
  name = "placey-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Role: RDS Proxy

resource "aws_iam_role" "rds_proxy" {
  name = "placey-${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-rds-proxy-role"
  })
}
