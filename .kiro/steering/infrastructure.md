# Infrastructure Quick Reference

Full spec: `docs/infrastructure-spec.md`

## Key Settings

- Region: us-east-1
- VPC CIDR: 10.0.0.0/16
- Private app subnets: 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b)
- Private data subnets: 10.0.3.0/24 (AZ-a), 10.0.4.0/24 (AZ-b)

## Security Groups

- `sg-lambda` → outbound 5432 to `sg-rds-proxy`, outbound 443 to VPC Endpoint
- `sg-rds-proxy` → inbound 5432 from `sg-lambda`, outbound 5432 to `sg-rds`
- `sg-rds` → inbound 5432 from `sg-rds-proxy`

## Resources

- Lambda: Node.js 24.x, 256 MB, 30s timeout, VPC-attached
- API Gateway: HTTP API (v2), CORS enabled
- RDS: PostgreSQL 16, db.t3.micro, PostGIS, 20 GB gp3
- RDS Proxy: PostgreSQL engine family, Secrets Manager auth
- Secrets Manager: `placey/db-credentials`, VPC Endpoint access
- S3: private, versioned, OAC with CloudFront
- CloudFront: OAC origin, SPA error routing, PriceClass_100

## Tagging

All resources: Project=placey, Environment=dev, ManagedBy=terraform, Team=team-4, Name=guillermo.romero@iteso.mx
