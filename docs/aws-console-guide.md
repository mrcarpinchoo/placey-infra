# AWS Console Guide

Step-by-step guide to build the Placey infrastructure through the AWS Console.

### Prerequisites

- AWS account with sufficient permissions
- Region set to `us-east-1` (N. Virginia)
- AWS CLI configured locally

---

### Developer Role Setup (Captain — Administrator account)

Before the team can provision resources, the captain must create the developer role and attach the required policies. Run these commands while authenticated with the Administrator account.

#### Create the developer role

```sh
ACCOUNT_ID=$(
  aws sts get-caller-identity \
    --query "Account"
    --output text
)

aws iam create-role \
  --role-name placey-dev-developer-role \
  --assume-role-policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Principal\": { \"AWS\": \"arn:aws:iam::$ACCOUNT_ID:root\" },
      \"Action\": \"sts:AssumeRole\"
    }]
  }"
```

#### Attach managed policies

```sh
for POLICY in \
  arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator \
  arn:aws:iam::aws:policy/AmazonRDSFullAccess \
  arn:aws:iam::aws:policy/AmazonS3FullAccess \
  arn:aws:iam::aws:policy/AmazonVPCFullAccess \
  arn:aws:iam::aws:policy/AWSLambda_FullAccess \
  arn:aws:iam::aws:policy/CloudFrontFullAccess \
  arn:aws:iam::aws:policy/CloudWatchFullAccessV2 \
  arn:aws:iam::aws:policy/SecretsManagerReadWrite
do
  aws iam attach-role-policy \
    --role-name placey-dev-developer-role \
    --policy-arn $POLICY
done
```

#### Add the PassRole inline policy

This allows the developer role to pass `placey-dev-rds-proxy-role` to the RDS Proxy service:
pass

```sh
aws iam put-role-policy \
  --role-name placey-dev-developer-role \
  --policy-name placey-dev-pass-rds-proxy-role \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::311141527383:role/placey-dev-rds-proxy-role"
    }]
  }'
```

---

### IAM Roles (Captain - Administrator Account)

The following roles must be created by the team captain using the Administrator account before the rest of the guide can be followed. Your `placey-dev-developer-role` does not have IAM permissions.

Run these commands while authenticated with the Administrator account.

```sh
ACCOUNT_ID=$(
  aws sts get-caller-identity \
    --query "Account" \
    --output text
)
```

1. Create the Lambda execution role:

    ```sh
    aws iam create-role \
      --role-name placey-dev-lambda-role \
      --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
          "Effect": "Allow",
          "Principal": { "Service": "lambda.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }]
      }' \
      --tags Key=Team,Value=team-4 Key=Owner,Value=guillermo.romero@iteso.mx
    ```

2. Attach managed policies to the Lambda role:

    ```sh
    aws iam attach-role-policy \
      --role-name placey-dev-lambda-role \
      --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole

    aws iam attach-role-policy \
      --role-name placey-dev-lambda-role \
      --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    ```

3. Add the inline policy to the Lambda role:

    > **Note**: Run this step only after completing Step 6 (Create the RDS Proxy). The `RDS_SECRET` variable fetches the ARN of the secret auto-created by RDS when you selected **Managed in AWS Secrets Manager**.

    ```sh
    PROXY_RESOURCE_ID=$(
      aws rds describe-db-proxies \
        --db-proxy-name placey-dev-rds-proxy \
        --query "DBProxies[0].DBProxyArn" \
        --output text
    )

    RDS_SECRET=$(
      aws rds describe-db-instances \
        --db-instance-identifier placey-dev-postgres-db01 \
        --query "DBInstances[0].MasterUserSecret.SecretArn" \
        --output text
    )

    aws iam put-role-policy \
      --role-name placey-dev-lambda-role \
      --policy-name placey-dev-lambda-secrets-policy \
      --policy-document "{
        \"Version\": \"2012-10-17\",
        \"Statement\": [
          {
            \"Effect\": \"Allow\",
            \"Action\": \"secretsmanager:GetSecretValue\",
            \"Resource\": \"$RDS_SECRET\"
          },
          {
            \"Effect\": \"Allow\",
            \"Action\": \"rds-db:connect\",
            \"Resource\": \"arn:aws:rds-db:us-east-1:$ACCOUNT_ID:dbuser:$PROXY_RESOURCE_ID/placey_admin\"
          }
        ]
      }"
    ```

4. Create the RDS Proxy role:

    ```sh
    aws iam create-role \
      --role-name placey-dev-rds-proxy-role \
      --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
          "Effect": "Allow",
          "Principal": { "Service": "rds.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }]
      }' \
      --tags Key=Team,Value=team-4 Key=Owner,Value=guillermo.romero@iteso.mx
    ```

5. Add the inline policy to the RDS Proxy role:

    > **Note**: Run this step only after completing Step 5 (Create the RDS Instance). The `RDS_SECRET` variable fetches the ARN of the secret auto-created by RDS.

    ```sh
    RDS_SECRET=$(
      aws rds describe-db-instances \
        --db-instance-identifier placey-dev-postgres-db01 \
        --query "DBInstances[0].MasterUserSecret.SecretArn" \
        --output text
    )

    aws iam put-role-policy \
      --role-name placey-dev-rds-proxy-role \
      --policy-name placey-dev-rds-proxy-secrets-policy \
      --policy-document "{
        \"Version\": \"2012-10-17\",
        \"Statement\": [{
          \"Effect\": \"Allow\",
          \"Action\": \"secretsmanager:GetSecretValue\",
          \"Resource\": \"$RDS_SECRET\"
        }]
      }"
    ```

### Tagging

The following two tags are required on RDS instances, Lambda functions, and S3 buckets. Add them in the **Tags** section of each resource's creation form.

| Key     | Value                       |
| ------- | --------------------------- |
| `Team`  | `team-4`                    |
| `Owner` | `guillermo.romero@iteso.mx` |

---

## Step 1 - Create the VPC

1. Go to **VPC** > **Your VPCs** > **Create VPC**.

2. Under **VPC settings**, set:
    - Resources to create: **VPC only**
    - Name tag: `placey-dev-vpc`
    - IPv4 CIDR block: **IPv4 CIDR manual input**
    - IPv4 CIDR: `10.0.0.0/16`
    - IPv6 CIDR block: **No IPv6 CIDR block**
    - Tenancy: **Default**

3. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

4. Click **Create VPC**.

5. Select the VPC > **Actions** > **Edit VPC settings**.

6. Under **DNS settings**, enable:
    - **Enable DNS resolution**
    - **Enable DNS hostnames**

7. Click **Save**.

## Step 2 - Create Subnets

1. Go to **VPC** > **Subnets** > **Create subnet**.

2. Under **VPC**, set:
    - VPC ID: `placey-dev-vpc`

3. Under **Subnet settings**, add all 3 subnets using **Add new subnet** for each:

    | Subnet name                         | Availability Zone | IPv4 CIDR block |
    | ----------------------------------- | ----------------- | --------------- |
    | `placey-dev-subnet-app-us-east-1a`  | us-east-1a        | `10.0.1.0/24`   |
    | `placey-dev-subnet-data-us-east-1a` | us-east-1a        | `10.0.3.0/24`   |
    | `placey-dev-subnet-data-us-east-1b` | us-east-1b        | `10.0.4.0/24`   |

4. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

5. Click **Create subnets**.

> **Note**: All subnets are private. Do not enable auto-assign public IPv4 on any of them.

> **Note**: The `placey-dev-subnet-data-us-east-1b` subnet exists solely to satisfy the RDS Proxy requirement of having subnets in at least 2 AZs. No resources are deployed there.

## Step 3 - Create Route Tables

### App Route Table

1. Go to **VPC** > **Route tables** > **Create route table**.

2. Under **Route table settings**, set:
    - Name: `placey-dev-rt-app`
    - VPC: `placey-dev-vpc`

3. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

4. Click **Create route table**.

5. Select it > **Subnet associations** tab > **Edit subnet associations** and select:
    - `placey-dev-subnet-app-us-east-1a`

6. Click **Save associations**.

### Data Route Table

1. Go to **VPC** > **Route tables** > **Create route table**.

2. Under **Route table settings**, set:
    - Name: `placey-dev-rt-data`
    - VPC: `placey-dev-vpc`

3. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

4. Click **Create route table**.

5. Select it > **Subnet associations** tab > **Edit subnet associations** and select:
    - `placey-dev-subnet-data-us-east-1a`
    - `placey-dev-subnet-data-us-east-1b`

6. Click **Save associations**.

> **Note**: Both route tables only need the default local route (`10.0.0.0/16 → local`). No internet or NAT routes are needed.

## Step 4 - Create Security Groups

All security groups belong to `placey-dev-vpc`. Create all four groups first with no rules, then add rules in a second pass — some rules reference other security groups by ID.

### 4.1 - Create All Security Groups (Empty)

Go to **VPC** > **Security groups** > **Create security group** for each:

1. For `placey-dev-sg-lambda`, set under **Basic details**:
    - Security group name: `placey-dev-sg-lambda`
    - Description: Security group for Lambda functions
    - VPC: `placey-dev-vpc`
    - Under **Outbound rules**, click **Delete** on the default `All traffic` rule.
    - Under **Tags**, add: `Team` = `team-4`, `Owner` = `guillermo.romero@iteso.mx`

2. For `placey-dev-sg-rds-proxy`, set under **Basic details**:
    - Security group name: `placey-dev-sg-rds-proxy`
    - Description: Security group for RDS Proxy
    - VPC: `placey-dev-vpc`
    - Under **Outbound rules**, click **Delete** on the default `All traffic` rule.
    - Under **Tags**, add: `Team` = `team-4`, `Owner` = `guillermo.romero@iteso.mx`

3. For `placey-dev-sg-rds`, set under **Basic details**:
    - Security group name: `placey-dev-sg-rds`
    - Description: Security group for RDS PostgreSQL
    - VPC: `placey-dev-vpc`
    - Under **Outbound rules**, click **Delete** on the default `All traffic` rule.
    - Under **Tags**, add: `Team` = `team-4`, `Owner` = `guillermo.romero@iteso.mx`

4. For `placey-dev-sg-vpc-endpoint`, set under **Basic details**:
    - Security group name: `placey-dev-sg-vpc-endpoint`
    - Description: Security group for Secrets Manager VPC Endpoint
    - VPC: `placey-dev-vpc`
    - Under **Outbound rules**, click **Delete** on the default `All traffic` rule.
    - Under **Tags**, add: `Team` = `team-4`, `Owner` = `guillermo.romero@iteso.mx`

### 4.2 - Add Rules

For `placey-dev-sg-lambda`:

1. Go to `placey-dev-sg-lambda` > **Outbound rules** tab > **Edit outbound rules**. Add:
    - Type: Custom TCP
    - Protocol: TCP
    - Port range: 5432
    - Destination: `placey-dev-sg-rds-proxy`
    - Description: Lambda to RDS Proxy
2. Add a second rule:
    - Type: HTTPS
    - Protocol: TCP
    - Port range: 443
    - Destination: `placey-dev-sg-vpc-endpoint`
    - Description: Lambda to Secrets Manager
3. Click **Save rules**.

For `placey-dev-sg-rds-proxy`:

1. Go to `placey-dev-sg-rds-proxy` > **Inbound rules** tab > **Edit inbound rules**. Add:
    - Type: Custom TCP
    - Protocol: TCP
    - Port range: 5432
    - Source: `placey-dev-sg-lambda`
    - Description: PostgreSQL from Lambda
2. Click **Save rules**.

3. Go to `placey-dev-sg-rds-proxy` > **Outbound rules** tab > **Edit outbound rules**. Add:
    - Type: Custom TCP
    - Protocol: TCP
    - Port range: 5432
    - Destination: `placey-dev-sg-rds`
    - Description: RDS Proxy to RDS
4. Click **Save rules**.

For `placey-dev-sg-rds`:

1. Go to `placey-dev-sg-rds` > **Inbound rules** tab > **Edit inbound rules**. Add:
    - Type: Custom TCP
    - Protocol: TCP
    - Port range: 5432
    - Source: `placey-dev-sg-rds-proxy`
    - Description: PostgreSQL from RDS Proxy
2. Add a second rule (maintenance access - disabled by default):
    - Type: Custom TCP
    - Protocol: TCP
    - Port range: 5432
    - Source: `0.0.0.0/32`
    - Description: Maintenance access - change source to My IP when needed, revert when done
3. Click **Save rules**.

For `placey-dev-sg-vpc-endpoint`:

1. Go to `placey-dev-sg-vpc-endpoint` > **Inbound rules** tab > **Edit inbound rules**. Add:
    - Type: HTTPS
    - Protocol: TCP
    - Port range: 443
    - Source: `placey-dev-sg-lambda`
    - Description: HTTPS from Lambda
2. Click **Save rules**.

## Step 5 - Create the RDS Instance

### 5.1 - Create DB Subnet Group

1. Go to **Aurora and RDS** > **Subnet groups** > **Create DB subnet group**.

2. Under **Subnet group details**, set:
    - Name: `placey-dev-subnet-group-postgres`
    - Description: DB subnet group for Placey PostgreSQL
    - VPC: `placey-dev-vpc`

3. Under **Add subnets**, set:
    - Availability Zones: `us-east-1a` and `us-east-1b`
    - Subnets:
        - `placey-dev-subnet-data-us-east-1a`
        - `placey-dev-subnet-data-us-east-1b`

4. Click **Create**.

### 5.2 - Create RDS Instance

1. Go to **Aurora and RDS** > **Databases** > **Create database** > **Full configuration**.

2. Under **Engine options**, set:
    - Engine type: **PostgreSQL**

3. Under **Choose a database creation method**, confirm:
    - **Full configuration** is selected

4. Under **Templates**, select:
    - **Dev/Test**

5. Under **Availability and durability**, set:
    - Deployment options: **Single-AZ DB instance deployment**

6. Under **Settings**, set:
    - Engine version: **PostgreSQL 16**
    - DB instance identifier: `placey-dev-postgres-db01`
    - Master username: `placey_admin`
    - Credentials management: **Managed in AWS Secrets Manager**
    - Encryption key: `aws/secretsmanager (default)`

7. Under **Instance configuration**, set:
    - DB instance class: **Burstable classes**
    - Instance type: `db.t3.micro`

8. Under **Storage**, set:
    - Storage type: **General Purpose SSD (gp3)**
    - Allocated storage: `20` GiB
    - Additional storage configuration > Storage autoscaling: **Disabled**

9. Under **Connectivity**, set:
    - Compute resource: **Don't connect to an EC2 compute resource**
    - Virtual private cloud (VPC): `placey-dev-vpc`
    - DB subnet group: `placey-dev-subnet-group-postgres`
    - Public access: **No**
    - VPC security group (firewall): **Choose existing**
    - Existing VPC security groups:
        - `placey-dev-sg-rds`
        - remove default
    - Availability Zone: `us-east-1a`
    - RDS Proxy: **leave unchecked** (we will create it manually in Step 6)

10. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

11. Under **Monitoring**, set:
    - Database Insights: **Database Insights - Standard**
    - Performance Insights: **Disabled**
    - Enhanced Monitoring: **Disabled**

12. Under **Additional configuration**, set:
    - **Database options**:
        - Initial database name: `placey`
    - **Backup**:
        - Backup retention period: `7` days
        - Deletion protection: **Disabled**

13. Click **Create database**.

> **Note**: Wait for the instance status to show **Available**. This can take 5–10 minutes.

> **Note**: AWS will create a Secrets Manager secret automatically and name it something like `rds!db-xxxxxxxx`. Note the secret name — you will need it when creating the RDS Proxy in Step 6.

> **Note**: PostGIS installation and database initialization are handled by the backend team. See `placey-backend` deploy guide.

## Step 6 - Create the RDS Proxy

1. Go to **Aurora and RDS** > **Proxies** > **Create proxy**.

2. Under **Proxy configuration**, set:
    - Engine family: **PostgreSQL**
    - Proxy identifier: `placey-dev-rds-proxy`
    - Idle client connection timeout: `0` hours `30` minutes

3. Under **Target group configuration**, set:
    - Database: `placey-dev-postgres-db01`
    - Target connection network type: **IPv4**
    - Connection pool maximum connections: `100`
    - Under **Additional target group configuration**:
        - Connection borrow timeout: `2` minutes `0` seconds

4. Under **Authentication**, set:
    - Identity and access management (IAM) role: `placey-dev-rds-proxy-role` (created by the captain in the prerequisites)
    - Secrets Manager secrets: select the secret auto-created by RDS (named `rds!db-xxxxxxxx`)
    - Client authentication type: **SCRAM SHA 256**
    - IAM authentication: **Not Allowed**

5. Under **Connectivity**, set:
    - Require Transport Layer Security: **Enabled**
    - Endpoint network type: **IPv4**
    - Subnets:
        - `placey-dev-subnet-data-us-east-1a`
        - `placey-dev-subnet-data-us-east-1b`
    - Under **Additional connectivity configuration**:
        - VPC security group: **Choose existing**
        - Existing VPC security groups:
            - `placey-dev-sg-rds-proxy`
            - remove default

6. Under **Advanced configuration**:
    - Enhanced logging: **leave unchecked**

7. Click **Create proxy**.

    > **Note**: Wait for the proxy status to show **Available**. This can take 5–10 minutes.

8. Once available, copy the **Proxy endpoint** — you will need it when configuring the Lambda environment variables.

## Step 7 - Create the VPC Endpoint for Secrets Manager

1. Go to **VPC** > **Endpoints** > **Create endpoint**.

2. Under **Endpoint settings**, set:
    - Name tag: `placey-dev-vpce-secretsmanager`
    - Type: **AWS services**

3. Under **Services**, search for `secretsmanager` and select:
    - `com.amazonaws.us-east-1.secretsmanager` (Type: Interface)

4. Under **Network settings**, set:
    - VPC: `placey-dev-vpc`
    - **Additional settings**:
        - Private DNS name: **enable**

5. Under **Subnets**, select:
    - `us-east-1a` - `placey-dev-subnet-app-us-east-1a`

6. Under **Security groups**, remove the default and select:
    - `placey-dev-sg-vpc-endpoint`

7. Under **Policy**, leave **Full access**.

8. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

9. Click **Create endpoint**.

## Step 8 - Attach the Lambda Inline Policy

Now that the RDS Proxy exists, the team captain must run prerequisite step 3 to attach the inline policy to `placey-dev-lambda-role`. This policy grants Lambda access to Secrets Manager and the RDS Proxy.

Refer back to the **IAM Roles** section in the prerequisites and run step 3.

## Step 9 - Create Lambda Functions

Repeat the following steps for each function:

| Function name              | Description      |
| -------------------------- | ---------------- |
| `placey-dev-search-places` | Proximity search |
| `placey-dev-get-place`     | Place details    |

1. Go to **Lambda** > **Functions** > **Create function**.

2. Select **Author from scratch**.

3. Under **Basic information**, set:
    - Function name: `<function-name>` (from table above)
    - Runtime: **Node.js 24.x**

4. Under **Additional settings**, enable and configure the following toggles:
    - Under **General**:
        - Enable **Custom execution role**, then set:
            - Execution role: `placey-dev-lambda-role`

    - Under **Networking**:
        - Enable **VPC**, then set:
            - VPC: `placey-dev-vpc`
            - Subnets: `placey-dev-subnet-app-us-east-1a`
            - Security groups: `placey-dev-sg-lambda`

    - Under **Security & governance**:
        - Enable **Tags**, then add:
            - `Team` = `team-4`
            - `Owner` = `guillermo.romero@iteso.mx`

5. Click **Create function**.

6. Go to the **Configuration** tab > **General configuration** > **Edit** and set:
    - Memory: `256` MB
    - Timeout: `0` min `30` sec
7. Click **Save**.

8. Go to **Configuration** > **Environment variables** > **Edit** and add:

    | Key                 | Value                              |
    | ------------------- | ---------------------------------- |
    | `DB_SECRET_ARN`     | ARN of the RDS-managed secret      |
    | `DB_PROXY_ENDPOINT` | Endpoint of `placey-dev-rds-proxy` |
    | `NODE_ENV`          | `dev`                              |

9. Click **Save**.

To retrieve the secret ARN:

```sh
aws rds describe-db-instances \
  --db-instance-identifier placey-dev-postgres-db01 \
  --query "DBInstances[0].MasterUserSecret.SecretArn" \
  --output text
```

To retrieve the proxy endpoint:

```sh
aws rds describe-db-proxies \
  --db-proxy-name placey-dev-rds-proxy \
  --query "DBProxies[0].Endpoint" \
  --output text
```

## Step 10 - Create the API Gateway

Go to **API Gateway** > **APIs** > **Create API** > **HTTP API** > **Build**.

### Step 1 - Configure API

1. Under **API details**, set:
    - API name: `placey-dev-api`
    - IP address type: **IPv4**

2. Under **Integrations**, click **Add integration** for each function:

    **Integration 1**:
    - Integration type: **Lambda**
    - AWS Region: `us-east-1`
    - Lambda function: `placey-dev-search-places`
    - Version: **2.0**

    **Integration 2**:
    - Integration type: **Lambda**
    - AWS Region: `us-east-1`
    - Lambda function: `placey-dev-get-place`
    - Version: **2.0**

3. Click **Next**.

### Step 2 - Configure routes

1. Add all routes:

    | Method | Resource path       | Integration target         |
    | ------ | ------------------- | -------------------------- |
    | GET    | `/places`           | `placey-dev-search-places` |
    | GET    | `/places/{placeId}` | `placey-dev-get-place`     |

2. Click **Next**.

### Step 3 - Define stages

1. Under **Configure stages**, set:
    - Stage name: `dev`
    - Auto-deploy: **Enabled**

2. Click **Next**.

### Step 4 - Review and create

1. Review the configuration and click **Create**.

Once created, go to the API > **Deploy** > **Stages**, select `dev` and copy the **Invoke URL**.

API Gateway HTTP API does not support tags during creation. After the API is created, go to the API > **Tags** and add:

- `Team` = `team-4`
- `Owner` = `guillermo.romero@iteso.mx`

### 11.1 - Enable CORS

1. Go to the API > **CORS** > **Configure**.

2. Under **Configure CORS**, set:
    - Access-Control-Allow-Origin: `*`
    - Access-Control-Allow-Headers: `content-type`
    - Access-Control-Allow-Methods: `GET, OPTIONS`

3. Click **Save**.

## Step 11 - Create the S3 Bucket

1. Go to **Amazon S3** > **Create bucket**.

2. Under **General configuration**, set:
    - AWS Region: `us-east-1`
    - Bucket type: **General purpose**
    - Bucket namespace: **Account Regional namespace**
    - Bucket name prefix: `placey-dev-frontend`

    > **Note**: AWS will append your account ID and region as a suffix. The full bucket name will look like `placey-dev-frontend-311141527383-us-east-1-an`.

3. Under **Object Ownership**, set:
    - Object Ownership: **ACLs disabled**

4. Under **Block Public Access settings for this bucket**, leave **Block all public access** enabled (default).

5. Under **Bucket Versioning**, set:
    - Bucket Versioning: **Enable**

6. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

7. Leave all other settings as default and click **Create bucket**.

## Step 12 - Create the CloudFront Distribution

### 12.1 - Create Origin Access Control

1. Go to **CloudFront** > **Origin access** > **Create control setting**.

2. Set:
    - Name: `placey-dev-oac`
    - Description: OAC for Placey frontend S3 bucket
    - Signing behavior: **Sign requests**
    - Origin type: **S3**

3. Click **Create**.

### 12.2 - Create Distribution

Go to **CloudFront** > **Distributions** > **Create distribution**.

#### Step 1 - Choose a plan

1. Select **Pay as you go**.
2. Click **Next**.

#### Step 2 - Get started

1. Under **Distribution options**, set:
    - Distribution name: `placey-dev-cloudfront`
    - Distribution type: **Single website or app**

2. Under **Domain**, leave empty (no custom domain for MVP).

3. Under **Tags**, add:
    - `Team` = `team-4`
    - `Owner` = `guillermo.romero@iteso.mx`

#### Step 3 - Specify origin

1. Under **Origin type**, set:
    - Origin type: **Amazon S3**

2. Under **Origin**, set:
    - S3 origin: select your bucket (`placey-dev-frontend-...`)
    - Origin path: leave empty

3. Under **Settings**, set:
    - Allow private S3 bucket access to CloudFront: Enable **Allow private S3 bucket access to CloudFront**
    - Origin settings: **Use recommended origin settings**
    - Cache settings: **Use recommended cache settings tailored to serving S3 content**

4. Click **Next**.

#### Step 4 - Enable security

1. Under **Web Application Firewall (WAF)**, select:
    - **Do not enable security protections**

2. Click **Next**.

#### Step 5 - Review and create

1. Review the configuration and click **Create distribution**.

2. Once created, copy the **Distribution domain name** (e.g., `https://<id>.cloudfront.net`) — this is your frontend URL.

### 12.3 - Configure SPA Error Routing

1. Go to **CloudFront** > **Distributions** > select `placey-dev-cloudfront` > **Error pages** tab > **Create custom error response**.

2. For the first rule, set:
    - HTTP error code: **403**
    - Customize error response: **Yes**
    - Response page path: `/index.html`
    - HTTP response code: **200**

3. Click **Create custom error response**.

4. Click **Create custom error response** again for the second rule, set:
    - HTTP error code: **404**
    - Customize error response: **Yes**
    - Response page path: `/index.html`
    - HTTP response code: **200**

5. Click **Create custom error response**.

## Cleanup

To tear down all resources and avoid ongoing charges, delete them in this order:

1. Delete the CloudFront distribution (disable first, wait for deployment, then delete)
2. Delete the CloudFront Origin Access Control (`placey-dev-oac`) — go to **CloudFront** > **Origin access** > select `placey-dev-oac` > **Delete**
3. Empty and delete the S3 bucket
4. Delete the API Gateway (`placey-dev-api`)
5. Delete the Lambda functions (all four)
6. Delete the RDS Proxy (`placey-dev-rds-proxy`) — wait for deletion to complete
7. Delete the RDS instance (`placey-dev-postgres-db01`) — skip final snapshot
8. Delete the DB subnet group (`placey-dev-subnet-group-postgres`)
9. Delete the Secrets Manager secret — go to **Secrets Manager** and delete the `rds!db-...` secret created by RDS
10. Delete the VPC Endpoint (`placey-dev-vpce-secretsmanager`)
11. Delete the IAM roles (`placey-dev-lambda-role`, `placey-dev-rds-proxy-role`)
12. Delete the Security Groups (all four `placey-dev-sg-*`)
13. Delete the Route Tables (`placey-dev-rt-app`, `placey-dev-rt-data`)
14. Delete the Subnets (all three)
15. Delete the VPC (`placey-dev-vpc`)
