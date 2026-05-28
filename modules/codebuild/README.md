# CodeBuild Module

This module creates an AWS CodeBuild project with IAM roles, policies, and optional VPC configuration for building and testing application code as part of a CI/CD pipeline.

## Resources Created

- `aws_codebuild_project` - CodeBuild project with build environment configuration
- `aws_iam_role` - IAM service role for CodeBuild
- `aws_iam_role_policy` - IAM policy with required permissions
- `aws_security_group` - Security group for CodeBuild (only when running in VPC)

## Usage

```hcl
module "codebuild" {
  source = "./modules/codebuild"

  name        = "myapp"
  description = "Build and push Docker image to ECR"

  # Build environment
  compute_type = "BUILD_GENERAL1_SMALL"
  build_image  = "aws/codebuild/standard:7.0"

  # Source
  source_type     = "GITHUB"
  source_location = "https://github.com/myorg/myapp.git"
  buildspec_path  = "buildspec.yml"

  # Artifacts
  artifacts_type = "CODEPIPELINE"

  # Environment variables
  environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-southeast-1"
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_REPO_NAME"
      value = "myapp"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PASSWORD"
      value = "/myapp/db_password"
      type  = "PARAMETER_STORE"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name prefix for all CodeBuild resources | `string` | - | ✅ |
| `description` | Description of the CodeBuild project | `string` | `""` | ❌ |
| `build_timeout` | Build timeout in minutes | `number` | `60` | ❌ |
| `compute_type` | Compute type for build environment | `string` | `BUILD_GENERAL1_SMALL` | ❌ |
| `build_image` | Docker image for build environment | `string` | `aws/codebuild/standard:7.0` | ❌ |
| `image_pull_credentials_type` | Credentials type for pulling build image | `string` | `CODEBUILD` | ❌ |
| `source_type` | Source provider type | `string` | `GITHUB` | ❌ |
| `source_location` | URL of the source repository | `string` | `""` | ❌ |
| `buildspec_path` | Path to buildspec file in repository | `string` | `buildspec.yml` | ❌ |
| `environment_variables` | Environment variables for build | `list(object)` | `[]` | ❌ |
| `artifacts_type` | Artifact output type | `string` | `NO_ARTIFACTS` | ❌ |
| `artifacts_bucket_name` | S3 bucket name for artifacts | `string` | `null` | ❌ |
| `vpc_id` | VPC ID for CodeBuild VPC configuration | `string` | `null` | ❌ |
| `subnet_ids` | Subnet IDs for VPC configuration | `list(string)` | `[]` | ❌ |
| `security_group_ids` | Security group IDs for VPC configuration | `list(string)` | `[]` | ❌ |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | ID of the CodeBuild project |
| `project_arn` | ARN of the CodeBuild project |
| `project_name` | Name of the CodeBuild project |
| `iam_role_arn` | ARN of the CodeBuild IAM role |
| `iam_role_name` | Name of the CodeBuild IAM role |
| `security_group_id` | ID of the CodeBuild security group (null if not in VPC) |

## Environment Variable Types

| Type | Use Case | Example |
|------|----------|---------|
| `PLAINTEXT` | Non-sensitive values | region, image name |
| `PARAMETER_STORE` | Sensitive values from SSM | `/myapp/db_password` |
| `SECRETS_MANAGER` | Secrets from Secrets Manager | `myapp/api_key` |

## Assumptions

- `privileged_mode` is enabled to support Docker build commands
- Build image uses `aws/codebuild/standard:7.0` which includes Docker, AWS CLI, and common build tools
- `git_clone_depth = 1` for faster cloning
- When `artifacts_type = "CODEPIPELINE"`, artifacts are managed by CodePipeline

## Notes

- Set `artifacts_type = "CODEPIPELINE"` when using with CodePipeline module
- For Docker builds, `privileged_mode` must remain `true`
- Use `PARAMETER_STORE` or `SECRETS_MANAGER` for sensitive environment variables instead of `PLAINTEXT`
- VPC configuration is optional but recommended when CodeBuild needs access to private resources