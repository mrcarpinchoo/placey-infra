# Network
module "network" {
  source = "../../modules/network"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  app_subnet_cidr    = var.app_subnet_cidr
  data_subnet_cidr_a = var.data_subnet_cidr_a
  data_subnet_cidr_b = var.data_subnet_cidr_b
  tags               = var.tags
}

# Security groups and IAM roles (no data dependency)
module "security" {
  source = "../../modules/security"

  environment   = var.environment
  vpc_id        = module.network.vpc_id
  app_subnet_id = module.network.app_subnet_id
  tags          = var.tags
}

# Data (RDS + RDS Proxy)
module "data" {
  source = "../../modules/data"

  environment        = var.environment
  data_subnet_ids    = module.network.data_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  rds_proxy_sg_id    = module.security.rds_proxy_sg_id
  rds_proxy_role_arn = module.security.rds_proxy_role_arn
  db_name            = var.db_name
  db_username        = var.db_username
  tags               = var.tags
}

# IAM inline policies — attached after data is created (needs secret ARN and proxy ARN)
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "placey-${var.environment}-lambda-secrets-policy"
  role = module.security.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = module.data.rds_secret_arn
      },
      {
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "${replace(module.data.rds_proxy_arn, ":db-proxy:", ":dbuser:")}/placey_admin"
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_proxy_secrets" {
  name = "placey-${var.environment}-rds-proxy-secrets-policy"
  role = module.security.rds_proxy_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = module.data.rds_secret_arn
    }]
  })
}

# Compute (Lambda + API Gateway)
module "compute" {
  source = "../../modules/compute"

  environment        = var.environment
  app_subnet_id      = module.network.app_subnet_id
  lambda_sg_id       = module.security.lambda_sg_id
  lambda_role_arn    = module.security.lambda_role_arn
  rds_secret_arn     = module.data.rds_secret_arn
  rds_proxy_endpoint = module.data.rds_proxy_endpoint
  tags               = var.tags
}

# Frontend (S3 + CloudFront)
module "frontend" {
  source = "../../modules/frontend"

  environment = var.environment
  tags        = var.tags
}
