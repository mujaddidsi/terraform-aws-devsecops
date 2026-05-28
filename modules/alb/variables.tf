variable "name" {
  description = "Name prefix for all ALB resources"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "subnet_ids" {
  description = "List of public subnet IDs for the ALB (minimum 2 for high availability)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets are required for high availability."
  }
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port on which the ECS containers are listening"
  type        = number
  default     = 80

  validation {
    condition     = var.target_port > 0 && var.target_port <= 65535
    error_message = "Target port must be between 1 and 65535."
  }
}

variable "target_protocol" {
  description = "Protocol for the target group (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "Target protocol must be HTTP or HTTPS."
  }
}

variable "health_check" {
  description = "Health check configuration for the target group"
  type = object({
    enabled             = bool
    path                = string
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    matcher             = string
  })
  default = {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener (optional)"
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}