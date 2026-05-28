# ECS Module

This module creates an Amazon ECS (Elastic Container Service) cluster using Fargate launch type, with task definition, ECS service, IAM roles, security groups, and CloudWatch logging.

## Resources Created

- `aws_ecs_cluster` - ECS Cluster with Container Insights enabled
- `aws_ecs_cluster_capacity_providers` - Fargate and Fargate Spot capacity providers
- `aws_ecs_task_definition` - Task definition with container configuration
- `aws_ecs_service` - ECS Service with deployment circuit breaker
- `aws_iam_role` - Task Execution Role and Task Role
- `aws_iam_role_policy_attachment` - Attach managed policy to execution role
- `aws_security_group` - Security group for ECS tasks
- `aws_cloudwatch_log_group` - Log group for container logs

## Usage

```hcl
module "ecs" {
  source = "./modules/ecs"

  name           = "myapp"
  vpc_id         = "vpc-xxxxxxxx"
  subnet_ids     = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
  container_image = "nginx:latest"
  container_port  = 80

  cpu           = 256
  memory        = 512
  desired_count = 2

  # From ALB module outputs
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id

  environment_variables = [
    { name = "APP_ENV", value = "production" },
    { name = "DB_HOST", value = "mydb.example.com" }
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
| `name` | Name prefix for all ECS resources | `string` | - | ✅ |
| `vpc_id` | VPC ID where ECS service will be deployed | `string` | - | ✅ |
| `subnet_ids` | List of private subnet IDs for ECS tasks | `list(string)` | - | ✅ |
| `container_image` | Docker image for the ECS task | `string` | - | ✅ |
| `target_group_arn` | ARN of the ALB target group | `string` | - | ✅ |
| `alb_security_group_id` | Security group ID of the ALB | `string` | - | ✅ |
| `container_port` | Port exposed by the container | `number` | `80` | ❌ |
| `cpu` | CPU units for the ECS task | `number` | `256` | ❌ |
| `memory` | Memory (MB) for the ECS task | `number` | `512` | ❌ |
| `desired_count` | Desired number of ECS task instances | `number` | `1` | ❌ |
| `environment_variables` | Environment variables for the container | `list(object)` | `[]` | ❌ |
| `enable_execute_command` | Enable ECS Exec for debugging | `bool` | `false` | ❌ |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | ID of the ECS cluster |
| `cluster_arn` | ARN of the ECS cluster |
| `cluster_name` | Name of the ECS cluster |
| `service_id` | ID of the ECS service |
| `service_name` | Name of the ECS service |
| `task_definition_arn` | ARN of the ECS task definition |
| `task_execution_role_arn` | ARN of the task execution IAM role |
| `task_role_arn` | ARN of the task IAM role |
| `security_group_id` | ID of the ECS tasks security group |
| `cloudwatch_log_group_name` | Name of the CloudWatch log group |

## Assumptions

- Using **ECS Fargate** as the launch type for serverless container management
- ECS tasks are deployed in **private subnets** for security
- Container logs are shipped to **CloudWatch Logs** with 30-day retention
- Deployment circuit breaker is enabled for **automatic rollback** on failed deployments
- Inbound traffic to containers is **only allowed from ALB** security group

## Notes

- `target_group_arn` and `alb_security_group_id` should be sourced from the ALB module outputs
- CPU and memory values must follow Fargate supported configurations
- `enable_execute_command` can be set to `true` for debugging purposes (not recommended in production)