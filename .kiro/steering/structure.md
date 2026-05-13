# Project Structure

This is the `placey-infra` repository. Placey uses a polyrepo architecture - the other repos are `placey-backend` and `placey-frontend`.

## This Repo (`placey-infra`)

Infrastructure as Code for all AWS cloud resources.

```
placey-infra/
  environments/
    dev/
      main.tf          # Composes all modules for the dev environment
      variables.tf     # Variable declarations
      provider.tf      # AWS provider configuration
      outputs.tf       # Output values (URLs, ARNs, etc.)
      dev.tfvars       # Dev-specific variable values
  modules/
    network/           # VPC, subnets, route tables, VPC endpoints
    security/          # Security groups, IAM roles and policies
    data/              # RDS, RDS Proxy
    compute/           # Lambda functions, API Gateway
    frontend/          # S3 bucket, CloudFront distribution
  docs/
    infrastructure-spec.md        # Full infrastructure specification
    resource-naming-conventions.md # AWS resource naming conventions
    aws-console-guide.md          # Step-by-step AWS Console guide
```

## Module Conventions

- Each module has `main.tf`, `variables.tf`, and `outputs.tf`
- Modules are composed in `environments/dev/main.tf`
- Modules are self-contained and reusable across environments

## Polyrepo Overview

| Repository        | Responsibility                                 |
| ----------------- | ---------------------------------------------- |
| `placey-infra`    | Terraform IaC - all AWS resource provisioning  |
| `placey-backend`  | Lambda functions, REST API, geospatial queries |
| `placey-frontend` | React app, map UI, search interface            |

- Each repo is independently deployable
- No shared code between repos - communicate via REST API
- Backend is the single source of truth for place data and proximity logic
