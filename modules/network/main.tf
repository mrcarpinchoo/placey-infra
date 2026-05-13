data "aws_region" "current" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-vpc"
  })
}

# Private app subnet (AZ-a) — Lambda
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnet_cidr
  availability_zone = "${data.aws_region.current.region}a"

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-subnet-app-${data.aws_region.current.region}a"
  })
}

# Private data subnet (AZ-a) — RDS primary, RDS Proxy
resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnet_cidr_a
  availability_zone = "${data.aws_region.current.region}a"

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-subnet-data-${data.aws_region.current.region}a"
  })
}

# Private data subnet (AZ-b) — required by RDS Proxy (no resources deployed here)
resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnet_cidr_b
  availability_zone = "${data.aws_region.current.region}b"

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-subnet-data-${data.aws_region.current.region}b"
  })
}

# Route table for app subnet (local only)
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-rt-app"
  })
}

resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

# Route table for data subnets (local only)
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "placey-${var.environment}-rt-data"
  })
}

resource "aws_route_table_association" "data_a" {
  subnet_id      = aws_subnet.data_a.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_b" {
  subnet_id      = aws_subnet.data_b.id
  route_table_id = aws_route_table.data.id
}
