# Deployment Guide

This guide provides step-by-step instructions for deploying the AWS DevSecOps infrastructure using Terraform.

## Prerequisites

Before you begin, ensure you have the following:

- **Terraform** >= 1.5.0 ([download](https://developer.hashicorp.com/terraform/downloads))
- **AWS CLI** >= 2.0 ([download](https://aws.amazon.com/cli/))
- **AWS Account** with AdministratorAccess or equivalent permissions
- **Git** installed on your local machine

## Step 1: AWS CLI Configuration

Configure AWS CLI with your credentials:

```bash
aws configure
```

Enter the following when prompted:
```
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: ap-southeast-1
Default output format: json
```

Verify configuration:
```bash
aws sts get-caller-identity
```

## Step 2: Create CodeStar Connection

CodeStar Connection cannot be created automatically by Terraform — it requires manual approval in AWS Console.

1. Open AWS Console → **Developer Tools** → **Settings** → **Connections**
2. Click **Create connection**
3. Select **GitHub** or **GitLab**
4. Enter a connection name (e.g. `indico-github`)
5. Click **Connect to GitHub/GitLab** and authorize AWS
6. Click **Install a new app** and select your repository
7. Click **Connect**
8. Copy the **Connection ARN** — you will need this for `terraform.tfvars`

## Step 3: Prepare Networking

You need an existing VPC with:
- At least **2 public subnets** (for ALB) in different availability zones
- At least **2 private subnets** (for ECS tasks) in different availability zones

To get your VPC and subnet IDs:
```bash
# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value]' --output table

# List subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone,MapPublicIpOnLaunch]' --output table
```

## Step 4: Clone and Configure

```bash
# Clone repository
git clone https://github.com/mujaddidsi/terraform-aws-devsecops.git
cd terraform-aws-devsecops

# Copy example variables
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your actual values:

```hcl
aws_region  = "ap-southeast-1"
name        = "indico"
environment = "production"

vpc_id             = "vpc-xxxxxxxxxxxxxxxx"
public_subnet_ids  = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
private_subnet_ids = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]

container_image = "nginx:latest"
container_port  = 80

source_type     = "GITHUB"
source_location = "https://github.com/your-org/your-repo.git"

repository_name         = "your-org/your-repo"
branch_name             = "main"
codestar_connection_arn = "arn:aws:codestar-connections:ap-southeast-1:123456789012:connection/xxx"
```

## Step 5: Prepare buildspec.yml

In your **application repository**, create a `buildspec.yml` file:

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$CODEBUILD_RESOLVED_SOURCE_VERSION

  build:
    commands:
      - echo Building Docker image...
      - docker build -t $IMAGE_URI .

  post_build:
    commands:
      - echo Pushing Docker image...
      - docker push $IMAGE_URI
      - printf '[{"name":"%s","imageUri":"%s"}]' $CONTAINER_NAME $IMAGE_URI > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
```

## Step 6: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply
```

Type `yes` when prompted to confirm.

## Step 7: Verify Deployment

After apply completes, verify your infrastructure:

```bash
# Get application endpoint
terraform output alb_dns_name

# Check ECS cluster
aws ecs describe-clusters --clusters indico-cluster

# Check ECS service
aws ecs describe-services \
  --cluster indico-cluster \
  --services indico-service

# Check pipeline status
aws codepipeline get-pipeline-state --name indico-pipeline
```

## Step 8: Trigger Pipeline

Push code to your repository to trigger the pipeline:

```bash
git push origin main
```

Monitor pipeline progress in AWS Console → **CodePipeline** → **indico-pipeline**

## Destroying Infrastructure

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

## Troubleshooting

**ECS tasks not starting:**
```bash
# Check task logs
aws logs get-log-events \
  --log-group-name /ecs/indico \
  --log-stream-name ecs/indico/<task-id>
```

**Pipeline failing at Build stage:**
```bash
# Check CodeBuild logs in AWS Console
# CodeBuild → Build projects → indico-build → Build history
```

**Pipeline failing at Deploy stage:**
- Ensure `imagedefinitions.json` is generated in `buildspec.yml`
- Ensure container name in `imagedefinitions.json` matches ECS task definition

## Limitations

| Limitation | Proposed Solution |
|---|---|
| CodeStar Connection requires manual approval | Use AWS CLI to create connection, still needs console approval |
| No ECR repository created | Add ECR module or create manually before first build |
| No auto-scaling configured | Add `aws_appautoscaling_target` and `aws_appautoscaling_policy` to ECS module |
| KMS key not created by module | Add KMS module or provide existing key ARN |