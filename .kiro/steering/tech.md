# Tech Stack

This is the `placey-infra` repository. It uses Terraform and AWS to provision all cloud resources for the Placey system.

## Infrastructure (`placey-infra`)

- Terraform for Infrastructure as Code
- AWS cloud provider (Region: us-east-1)

## AWS Architecture (MVP)

### Frontend (Global)

- CloudFront — CDN for serving the React app globally
- S3 — hosts the static React build

### Backend (Regional, us-east-1)

- API Gateway — HTTP entry point for the REST API
- Lambda Functions — serverless compute, one function per API endpoint, deployed in a private subnet within the VPC. Number of functions scales with the number of routes. Runtime: Node.js 24.x.
- RDS Proxy — connection pooling between Lambda and PostgreSQL
- RDS PostgreSQL + PostGIS — primary database for places and reviews with geospatial queries

### Networking

- VPC with private subnets (application tier and database tier)
- VPC Endpoint for Secrets Manager (private access from Lambda)

### Security

- Secrets Manager — stores DB credentials, accessed by Lambda via VPC Endpoint
- Security Groups — network-level access control between components
- IAM Roles — least-privilege access for Lambda

### Observability

- CloudWatch — logs and metrics from API Gateway, Lambda, RDS
- CloudWatch Alarms — alerting on error rates and latency

### CI/CD (post-MVP, if time permits)

- CodePipeline + CodeBuild — automated Lambda deployment pipeline

## Development Environment

- AWS CLI and Terraform run via Docker Compose (no local installation needed)
- AWS credentials loaded from `.env` file (see `.env.example`)
- **Never read `.env` — it contains sensitive AWS credentials**
- Run containers: `docker compose up -d`
- Drop into Terraform shell: `docker exec -it <terraform-container> sh`
- Drop into AWS CLI shell: `docker exec -it <aws-cli-container> sh`

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

## API Endpoints

- `GET /places?lat=&lon=&radius=&category=` — proximity search
- `GET /places/{placeId}` — place details
- `GET /places/{placeId}/reviews` — reviews for a place
- `POST /places/{placeId}/reviews` — submit a review (no auth for MVP)

## Other Repos (for reference)

- `placey-backend`: Lambda functions, REST API, geospatial queries, PostgreSQL + PostGIS
- `placey-frontend`: React, OpenStreetMap or Mapbox
