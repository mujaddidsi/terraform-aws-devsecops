output "pipeline_id" {
  description = "ID of the CodePipeline pipeline"
  value       = aws_codepipeline.this.id
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline pipeline"
  value       = aws_codepipeline.this.arn
}

output "pipeline_name" {
  description = "Name of the CodePipeline pipeline"
  value       = aws_codepipeline.this.name
}

output "artifacts_bucket_name" {
  description = "Name of the S3 bucket used for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the S3 bucket used for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.arn
}

output "iam_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline.arn
}

output "iam_role_name" {
  description = "Name of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline.name
}