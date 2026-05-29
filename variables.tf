variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "indico"
}

variable "environment" {
  description = "Environment name (e.g. production, staging, development)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be production, staging, or development."
  }
}

# Networking
variable "vpc_id" {
  description = "VPC ID where all resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

# ECS
variable "container_image" {
  description = "Docker image for the ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS task instances"
  type        = number
  default     = 2
}

# CodeBuild
variable "source_type" {
  description = "Source provider type for CodeBuild (GITHUB, GITLAB)"
  type        = string
  default     = "GITHUB"
}

variable "source_location" {
  description = "URL of the source repository"
  type        = string
}

variable "buildspec_path" {
  description = "Path to the buildspec file"
  type        = string
  default     = "buildspec.yml"
}

# CodePipeline
variable "repository_name" {
  description = "Repository name for CodePipeline (e.g. myorg/myrepo)"
  type        = string
}

variable "branch_name" {
  description = "Branch name to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection for GitHub/GitLab"
  type        = string
}

# ALB
variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (optional)"
  type        = string
  default     = null
}

# Security
variable "kms_key_arn" {
  description = "ARN of KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}