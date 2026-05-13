# placey-infra

Terraform infrastructure as code for the Placey system. Provisions and manages all AWS cloud resources for the `dev` environment.

## What is Placey?

Placey is a proximity-based application that helps users discover nearby recreational places based on their current location. It is built as an educational MVP for a System Design course.

## Polyrepo Architecture

Placey is split across three repositories:

| Repository        | Responsibility                                            |
| ----------------- | --------------------------------------------------------- |
| `placey-infra`    | Terraform IaC - all AWS resource provisioning (this repo) |
| `placey-backend`  | Lambda functions, REST API, geospatial queries            |
| `placey-frontend` | React app, map UI, search interface                       |

Each repo is independently deployable. No shared code between repos.

## AWS Architecture

- **Frontend:** CloudFront, S3 (static React app).
- **Backend:** API Gateway, Lambda (Node.js 24.x), RDS Proxy, PostgreSQL 16 with PostGIS.
- **Networking:** VPC with private subnets, VPC Endpoint for Secrets Manager.
- **Security:** Secrets Manager, Security Groups, IAM roles.

All resources are provisioned in `us-east-1`.

## Documentation

- [`docs/infrastructure-spec.md`](docs/infrastructure-spec.md): full infrastructure specification
- [`docs/resource-naming-conventions.md`](docs/resource-naming-conventions.md): AWS resource naming conventions
- [`docs/aws-console-guide.md`](docs/aws-console-guide.md): step-by-step AWS Console provisioning guide

## Development

AWS credentials are loaded from `.env` (see `.env.example`). Never commit `.env`.

```sh
# Export credentials
export $(cat .env | xargs)

# Plan
terraform -chdir=environments/dev plan -var-file=dev.tfvars

# Apply
terraform -chdir=environments/dev apply -var-file=dev.tfvars
```

## Authors

Developed as part of a System Design course - Team 4.
