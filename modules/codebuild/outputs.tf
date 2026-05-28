output "project_id" {
  description = "ID of the CodeBuild project"
  value       = aws_codebuild_project.this.id
}

output "project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.this.arn
}

output "project_name" {
  description = "Name of the CodeBuild project - used by CodePipeline"
  value       = aws_codebuild_project.this.name
}

output "iam_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild.arn
}

output "iam_role_name" {
  description = "Name of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild.name
}

output "security_group_id" {
  description = "ID of the CodeBuild security group (null if not running in VPC)"
  value       = var.vpc_id != null ? aws_security_group.codebuild[0].id : null
}