variable "name" {
  description = "Name prefix for all CodePipeline resources"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }
}

variable "source_provider" {
  description = "Source provider for CodePipeline (GitHub, GitLab, CodeCommit)"
  type        = string
  default     = "GitHub"

  validation {
    condition     = contains(["GitHub", "GitLab", "CodeCommit"], var.source_provider)
    error_message = "Source provider must be GitHub, GitLab, or CodeCommit."
  }
}

variable "repository_name" {
  description = "Name of the source repository (e.g. myorg/myrepo)"
  type        = string
}

variable "branch_name" {
  description = "Branch name to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project for the build stage"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster for the deploy stage"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service for the deploy stage"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection for GitHub/GitLab source"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts (optional, will be created if not provided)"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "ARN of KMS key for S3 artifact encryption (optional)"
  type        = string
  default     = null
}

variable "enable_webhook" {
  description = "Enable webhook for automatic pipeline trigger on code push"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}