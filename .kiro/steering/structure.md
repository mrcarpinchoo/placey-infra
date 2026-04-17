# Project Structure

This is the `placey-infra` repository. Placey uses a polyrepo architecture — the other repos are `placey-backend` and `placey-frontend`.

## This Repo (`placey-infra`)

Infrastructure as Code for all cloud resources.

```
placey-infra/
  environments/                   # Per-environment configurations
    dev/
      main.tf                     # Core resources for dev
      variables.tf                # Dev-specific variable declarations
      provider.tf                 # Provider configuration for dev
      outputs.tf                  # Output values for dev resources
      dev.tfvars                  # Dev-specific variable values
  modules/                        # Centralized reusable Terraform modules
    network/
      main.tf                     # VPC, subnets, VPC endpoints
      variables.tf                # Input variables for network settings
      outputs.tf                  # Outputs for VPC, subnet IDs
    compute/
      main.tf                     # Lambda functions, API Gateway
      variables.tf                # Input variables for compute settings
      outputs.tf                  # Outputs for function ARNs, API URLs
    data/
      main.tf                     # RDS, RDS Proxy, Secrets Manager
      variables.tf                # Input variables for data settings
      outputs.tf                  # Outputs for DB endpoints, secret ARNs
    security/
      main.tf                     # Security groups, IAM roles
      variables.tf                # Input variables for security settings
      outputs.tf                  # Outputs for SG IDs, role ARNs
    frontend/
      main.tf                     # CloudFront, S3 bucket
      variables.tf                # Input variables for frontend settings
      outputs.tf                  # Outputs for CloudFront URL, bucket name
    monitoring/
      main.tf                     # CloudWatch, CloudWatch Alarms
      variables.tf                # Input variables for monitoring settings
      outputs.tf                  # Outputs for alarm ARNs
```

Note: `staging/` and `prod/` environment folders will be added later.

## Module Conventions

- Each module has `main.tf`, `variables.tf`, and `outputs.tf`
- Modules are composed in environment-level `main.tf`
- Modules should be self-contained and reusable across environments

## `placey-backend`

Core API and geospatial logic (Lambda functions).

```
placey-backend/
  src/
    routes/         # API route handlers (e.g., /places)
    services/       # Business logic (proximity search, filtering)
    models/         # Data models (Place, Category)
    db/             # Database connection and query helpers
  tests/
```

## `placey-frontend`

React application with map and search UI.

```
placey-frontend/
  src/
    components/     # UI components (Map, SearchBar, PlaceCard, Filters)
    pages/          # Page-level components
    services/       # API client calls to backend
  public/
```

## Conventions

- Each repo is independently deployable
- No shared code between repos — communicate via REST API
- Backend is the single source of truth for place data and proximity logic
- Frontend never performs geospatial calculations directly
