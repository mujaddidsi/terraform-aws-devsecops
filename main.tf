terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.name
    })
  }
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  name       = var.name
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids
  internal   = false

  target_port     = var.container_port
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

  certificate_arn = var.certificate_arn

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  name           = var.name
  vpc_id         = var.vpc_id
  subnet_ids     = var.private_subnet_ids
  container_image = var.container_image
  container_port  = var.container_port

  cpu           = var.cpu
  memory        = var.memory
  desired_count = var.desired_count

  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id

  environment_variables = [
    {
      name  = "APP_ENV"
      value = var.environment
    }
  ]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# CodeBuild Module
module "codebuild" {
  source = "./modules/codebuild"

  name        = var.name
  description = "Build and push Docker image to ECR for ${var.name}"

  compute_type    = "BUILD_GENERAL1_SMALL"
  build_image     = "aws/codebuild/standard:7.0"
  source_type     = var.source_type
  source_location = var.source_location
  buildspec_path  = var.buildspec_path
  artifacts_type  = "CODEPIPELINE"

  environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_REPO_NAME"
      value = var.name
      type  = "PLAINTEXT"
    },
    {
      name  = "CONTAINER_NAME"
      value = var.name
      type  = "PLAINTEXT"
    }
  ]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# CodePipeline Module
module "codepipeline" {
  source = "./modules/codepipeline"

  name = var.name

  source_provider         = "GitHub"
  repository_name         = var.repository_name
  branch_name             = var.branch_name
  codestar_connection_arn = var.codestar_connection_arn

  codebuild_project_name = module.codebuild.project_name
  ecs_cluster_name       = module.ecs.cluster_name
  ecs_service_name       = module.ecs.service_name

  kms_key_arn = var.kms_key_arn

  tags = merge(var.tags, {
    Environment = var.environment
  })
}