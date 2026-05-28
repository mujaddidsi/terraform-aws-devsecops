variable "name" {
  description = "Name prefix for all CodeBuild resources"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }
}

variable "description" {
  description = "Description of the CodeBuild project"
  type        = string
  default     = ""
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.build_timeout >= 5 && var.build_timeout <= 480
    error_message = "Build timeout must be between 5 and 480 minutes."
  }
}

variable "compute_type" {
  description = "Compute type for the build environment"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition = contains([
      "BUILD_GENERAL1_SMALL",
      "BUILD_GENERAL1_MEDIUM",
      "BUILD_GENERAL1_LARGE",
      "BUILD_GENERAL1_XLARGE"
    ], var.compute_type)
    error_message = "Invalid compute type."
  }
}

variable "build_image" {
  description = "Docker image for the build environment"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "image_pull_credentials_type" {
  description = "Type of credentials for pulling the build image"
  type        = string
  default     = "CODEBUILD"

  validation {
    condition     = contains(["CODEBUILD", "SERVICE_ROLE"], var.image_pull_credentials_type)
    error_message = "Must be CODEBUILD or SERVICE_ROLE."
  }
}

variable "source_type" {
  description = "Source provider type (GITHUB, GITLAB, CODECOMMIT, S3, NO_SOURCE)"
  type        = string
  default     = "GITHUB"

  validation {
    condition     = contains(["GITHUB", "GITLAB", "CODECOMMIT", "S3", "NO_SOURCE"], var.source_type)
    error_message = "Invalid source type."
  }
}

variable "source_location" {
  description = "URL of the source repository (e.g. https://github.com/org/repo.git)"
  type        = string
  default     = ""
}

variable "buildspec_path" {
  description = "Path to the buildspec file in the repository"
  type        = string
  default     = "buildspec.yml"
}

variable "environment_variables" {
  description = "Environment variables for the build environment"
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "artifacts_type" {
  description = "Artifact output type (NO_ARTIFACTS, S3, CODEPIPELINE)"
  type        = string
  default     = "NO_ARTIFACTS"

  validation {
    condition     = contains(["NO_ARTIFACTS", "S3", "CODEPIPELINE"], var.artifacts_type)
    error_message = "Must be NO_ARTIFACTS, S3, or CODEPIPELINE."
  }
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for artifacts (required if artifacts_type is S3)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for CodeBuild to run inside VPC (optional)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for CodeBuild VPC configuration (optional)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for CodeBuild VPC configuration (optional)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}