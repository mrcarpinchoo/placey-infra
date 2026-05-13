# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "placey-${var.environment}-subnet-group-postgres"
  subnet_ids = var.data_subnet_ids

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-subnet-group-postgres"
  })
}

# RDS PostgreSQL instance
resource "aws_db_instance" "main" {
  identifier        = "placey-${var.environment}-postgres-db01"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username

  # Credentials managed by Secrets Manager — AWS auto-creates and rotates the secret
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  availability_zone       = "us-east-1a"
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = var.tags
}

# RDS Proxy
resource "aws_db_proxy" "main" {
  name                   = "placey-${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = var.rds_proxy_role_arn
  vpc_security_group_ids = [var.rds_proxy_sg_id]
  vpc_subnet_ids         = var.data_subnet_ids

  auth {
    auth_scheme               = "SECRETS"
    iam_auth                  = "DISABLED"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    secret_arn                = aws_db_instance.main.master_user_secret[0].secret_arn
  }

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-rds-proxy"
  })

  depends_on = [aws_db_instance.main]
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    max_connections_percent   = 100
    connection_borrow_timeout = 120
  }
}

resource "aws_db_proxy_target" "main" {
  db_instance_identifier = aws_db_instance.main.identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}
