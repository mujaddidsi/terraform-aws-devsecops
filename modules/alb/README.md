# ALB Module

This module creates an Application Load Balancer (ALB) on AWS with target group, listeners, and security group configurations.

## Resources Created

- `aws_lb` - Application Load Balancer
- `aws_lb_target_group` - Target group for ECS containers
- `aws_lb_listener` - HTTP listener (port 80)
- `aws_lb_listener` - HTTPS listener (port 443, optional)
- `aws_security_group` - Security group for ALB

## Usage

```hcl
module "alb" {
  source = "./modules/alb"

  name       = "myapp"
  vpc_id     = "vpc-xxxxxxxx"
  subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]

  target_port     = 80
  target_protocol = "HTTP"

  health_check = {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Optional: enable HTTPS
  certificate_arn = "arn:aws:acm:ap-southeast-1:123456789:certificate/xxx"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name prefix for all ALB resources | `string` | - | ✅ |
| `vpc_id` | VPC ID where the ALB will be deployed | `string` | - | ✅ |
| `subnet_ids` | List of public subnet IDs (minimum 2) | `list(string)` | - | ✅ |
| `internal` | Whether the ALB is internal or internet-facing | `bool` | `false` | ❌ |
| `target_port` | Port on which ECS containers are listening | `number` | `80` | ❌ |
| `target_protocol` | Protocol for the target group | `string` | `"HTTP"` | ❌ |
| `health_check` | Health check configuration | `object` | see variables.tf | ❌ |
| `certificate_arn` | ARN of ACM certificate for HTTPS | `string` | `null` | ❌ |
| `enable_deletion_protection` | Enable deletion protection on ALB | `bool` | `false` | ❌ |
| `allowed_cidr_blocks` | CIDR blocks allowed to access ALB | `list(string)` | `["0.0.0.0/0"]` | ❌ |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | ❌ |

## Outputs

| Name | Description |
|------|-------------|
| `alb_arn` | ARN of the Application Load Balancer |
| `alb_dns_name` | DNS name of the Application Load Balancer |
| `alb_zone_id` | Hosted zone ID of the Application Load Balancer |
| `target_group_arn` | ARN of the target group |
| `target_group_name` | Name of the target group |
| `security_group_id` | ID of the ALB security group |
| `http_listener_arn` | ARN of the HTTP listener |
| `https_listener_arn` | ARN of the HTTPS listener (null if no certificate) |

## Notes

- Target type is set to `ip` for compatibility with ECS Fargate
- HTTP traffic is automatically redirected to HTTPS when `certificate_arn` is provided
- HTTPS listener uses `ELBSecurityPolicy-TLS13-1-2-2021-06` security policy
- Minimum 2 subnets required for high availability