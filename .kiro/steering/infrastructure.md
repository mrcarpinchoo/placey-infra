# Infrastructure Quick Reference

Full spec: `docs/infrastructure-spec.md`

## Key Settings

- Region: us-east-1
- VPC CIDR: 10.0.0.0/16
- Private app subnet: 10.0.1.0/24 (AZ-a) - Lambda
- Private data subnets: 10.0.3.0/24 (AZ-a), 10.0.4.0/24 (AZ-b) - RDS, RDS Proxy

## Security Groups

- `sg-lambda` → outbound 5432 to `sg-rds-proxy`, outbound 443 to `sg-vpc-endpoint`
- `sg-rds-proxy` → inbound 5432 from `sg-lambda`, outbound 5432 to `sg-rds`
- `sg-rds` → inbound 5432 from `sg-rds-proxy`
- `sg-vpc-endpoint` → inbound 443 from `sg-lambda`

## Resources

- Lambda: Node.js 22.x, 256 MB, 30s timeout, VPC-attached
- API Gateway: HTTP API (v2), CORS enabled (GET, OPTIONS)
- RDS: PostgreSQL 16, db.t3.micro, PostGIS, 20 GB gp3, managed credentials
- RDS Proxy: PostgreSQL engine family, Secrets Manager auth, TLS required
- Secrets Manager: auto-created by RDS (`rds!db-...`), accessed via VPC Endpoint
- S3: private, versioned, Account Regional namespace, OAC with CloudFront
- CloudFront: OAC origin, SPA error routing, pay-as-you-go

## Tagging

Required on RDS instances, Lambda functions, and S3 buckets:

- `Team` = `team-4`
- `Owner` = `guillermo.romero@iteso.mx`
