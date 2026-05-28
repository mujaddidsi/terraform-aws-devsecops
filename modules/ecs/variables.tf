variable "name" {
  description = "Name prefix for all ECS resources"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ECS service will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets are required for high availability."
  }
}

variable "container_image" {
  description = "Docker image for the ECS task (e.g. nginx:latest)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "cpu" {
  description = "CPU units for the ECS task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Memory (MB) for the ECS task (512, 1024, 2048, 4096, 8192)"
  type        = number
  default     = 512

  validation {
    condition     = contains([512, 1024, 2048, 4096, 8192], var.memory)
    error_message = "Memory must be one of: 512, 1024, 2048, 4096, 8192."
  }
}

variable "desired_count" {
  description = "Desired number of ECS task instances"
  type        = number
  default     = 1
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to associate with ECS service"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB to allow inbound traffic to ECS tasks"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging into containers"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}