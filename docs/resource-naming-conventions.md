# AWS Resource Naming Conventions

## General Guidelines

- **Descriptive names:** Names should reflect the resource's purpose. Use `web-prod-server1` instead of `server1`.
- **Lowercase only:** Avoids case sensitivity issues and promotes uniformity.
- **Allowed characters:** Alphanumeric characters and hyphens only. No spaces or special characters.
- **Include environment:** Always specify the environment (`dev`, `test`, `prod`) to differentiate resources across deployment stages.
- **Use tags:** AWS tags provide additional metadata beyond the name (e.g., owner, cost center, project).

---

## Resource-Specific Conventions

- **EC2 Instances**
  - Format: `[project]-[env]-[role]-[identifier]`
  - Example: `placey-dev-bastion-01`

- **S3 Buckets**
  - Format: `[project]-[env]-[purpose]-[account-regional-namespace-suffix]`
  - Example: `placey-dev-frontend-123456789012-us-east-1-an`

- **IAM Roles**
  - Format: `[project]-[env]-[component]-role`
  - Example: `placey-dev-lambda-role`, `placey-dev-rds-proxy-role`

- **IAM Policies**
  - Format: `[project]-[env]-[component]-[purpose]-policy`
  - Example: `placey-dev-lambda-secrets-policy`

- **RDS Instances**
  - Format: `[project]-[env]-[database-type]-[identifier]`
  - Example: `placey-dev-postgres-db01`

- **RDS Proxy**
  - Format: `[project]-[env]-rds-proxy`
  - Example: `placey-dev-rds-proxy`

- **DB Subnet Groups**
  - Format: `[project]-[env]-subnet-group-[database-type]`
  - Example: `placey-dev-subnet-group-postgres`

- **Lambda Functions**
  - Format: `[project]-[env]-[function-purpose]`
  - Example: `placey-dev-search-places`, `placey-dev-get-place`, `placey-dev-get-reviews`, `placey-dev-create-review`

- **API Gateway**
  - Format: `[project]-[env]-api-gateway`
  - Example: `placey-dev-api-gateway`

- **CloudFront Distributions**
  - Format: identified by comment/tag `[project]-[env]-cloudfront`
  - Example: `placey-dev-cloudfront`

- **CloudFront Origin Access Control**
  - Format: `[project]-[env]-oac`
  - Example: `placey-dev-oac`

- **CloudFormation Stacks**
  - Format: `[project]-[env]-[purpose]`
  - Example: `placey-dev-infrastructure`

- **VPC**
  - Format: `[project]-[env]-vpc`
  - Example: `placey-dev-vpc`

- **Subnets**
- Format: `[project]-[env]-[tier]-subnet-[availability-zone]`
- Example: `placey-dev-app-subnet-us-east-1a`, `placey-dev-data-subnet-us-east-1b`

- **Security Groups**
  - Format: `[project]-[env]-sg-[purpose]`
  - Example: `placey-dev-sg-lambda`, `placey-dev-sg-rds-proxy`, `placey-dev-sg-web`, `placey-dev-sg-vpc-endpoint`

- **VPC Endpoints**
  - Format: `[project]-[env]-vpce-[service]`
  - Example: `placey-dev-vpce-secrets-manager`

- **Route Tables**
  - Format: `[project]-[env]-rt-[scope]`
  - Example: `placey-dev-rt-app`, `placey-dev-rt-data`

- **Secrets Manager Secrets**
  - Format: `[project]/[env]/[purpose]`
  - Example: `placey/dev/db-credentials`

- **CloudWatch Log Groups**
  - Format: `/aws/lambda/[function-name]` (AWS-managed convention)
  - Example: `/aws/lambda/placey-dev-search-places`

- **CloudWatch Alarms**
  - Format: `[project]-[env]-[component]-[metric]`
  - Example: `placey-dev-api-gateway-5xx-errors`, `placey-dev-lambda-search-places-errors`, `placey-dev-rds-cpu`

- **Internet Gateways**
  - Format: `[project]-[env]-igw`
  - Example: `placey-dev-igw`

- **NAT Gateways**
  - Format: `[project]-[env]-nat-[availability-zone]`
  - Example: `placey-dev-nat-us-east-1a`

- **Elastic Load Balancers**
  - Format: `[project]-[env]-elb-[purpose]`
  - Example: `placey-dev-elb-web`

- **Target Groups**
  - Format: `[project]-[env]-tg-[purpose]`
  - Example: `placey-dev-tg-web`

- **Auto Scaling Groups**
  - Format: `[project]-[env]-asg-[purpose]`
  - Example: `placey-dev-asg-web`

- **Launch Templates**
  - Format: `[project]-[env]-lt-[purpose]`
  - Example: `placey-dev-lt-web`
