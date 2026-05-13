# Tech Stack

This is the `placey-infra` repository. It uses Terraform and AWS to provision all cloud resources for the Placey system.

## Infrastructure (`placey-infra`)

- Terraform for Infrastructure as Code
- AWS cloud provider (Region: us-east-1)

## AWS Architecture (MVP)

### Frontend (Global)

- CloudFront - CDN for serving the React app globally
- S3 - hosts the static React build (Account Regional namespace)

### Backend (Regional, us-east-1)

- API Gateway - HTTP API (v2), entry point for the REST API
- Lambda Functions - Node.js 24.x, one function per route, deployed in a private VPC subnet
- RDS Proxy - connection pooling between Lambda and PostgreSQL
- RDS PostgreSQL 16 + PostGIS - primary database, managed credentials via Secrets Manager

### Networking

- VPC with private subnets (app tier and data tier)
- VPC Endpoint for Secrets Manager (private access from Lambda, no internet required)

### Security

- Secrets Manager - DB credentials auto-managed by RDS
- Security Groups - network-level access control between components
- IAM Roles - least-privilege access for Lambda and RDS Proxy

### CI/CD (post-MVP)

- CodePipeline + CodeBuild - automated deployment pipeline

## Development Environment

- AWS CLI and Terraform installed locally
- AWS credentials loaded from `.env` (see `.env.example`) - export before running Terraform
- **Never read `.env` - it contains sensitive AWS credentials**

## Terraform State

- Backend: local
- State file: `environments/dev/terraform.tfstate` (not committed to git)

## Terraform Version Constraints

- Terraform: `~> 1.12`
- AWS Provider: `~> 5.0`

```hcl
terraform {
  required_version = "~> 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
