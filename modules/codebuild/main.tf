locals {
  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "codebuild"
  })
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild" {
  name = "${var.name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.name}-codebuild-role"
  })
}

# IAM Policy for CodeBuild
resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security Group for CodeBuild (only when running in VPC)
resource "aws_security_group" "codebuild" {
  count = var.vpc_id != null ? 1 : 0

  name        = "${var.name}-codebuild-sg"
  description = "Security group for ${var.name} CodeBuild project"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.name}-codebuild-sg"
  })
}

# CodeBuild Project
resource "aws_codebuild_project" "this" {
  name          = "${var.name}-build"
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type       = var.artifacts_type
    location   = var.artifacts_type == "S3" ? var.artifacts_bucket_name : null
    packaging  = var.artifacts_type == "S3" ? "ZIP" : null
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  source {
    type            = var.source_type
    location        = var.source_location != "" ? var.source_location : null
    buildspec       = var.buildspec_path
    git_clone_depth = 1

    dynamic "git_submodules_config" {
      for_each = var.source_type != "NO_SOURCE" && var.source_type != "S3" ? [1] : []
      content {
        fetch_submodules = false
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_ids
      security_group_ids = concat(
        [aws_security_group.codebuild[0].id],
        var.security_group_ids
      )
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/${var.name}"
      stream_name = "build-log"
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-build"
  })
}