terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for common tags
locals {
  common_tags = {
    Environment     = var.environment
    resourcecreator = var.ResourceCreator
  }
}

# S3 Module
module "s3" {
  source      = "./modules/s3"
  bucket_name = "deel-test-app-bucket-${var.environment}"
  tags        = local.common_tags
}

# ECR Module
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "deel-test-app"
  tags            = local.common_tags
}

# IAM Module
module "iam" {
  source    = "./modules/iam"
  role_name = "deel-test-app-ecs-task-execution-role"
  tags      = local.common_tags
}

# ALB Module
module "alb" {
  source              = "./modules/alb"
  name_prefix         = "deel-test-app"
  alb_name            = "deel-test-app-alb"
  target_group_name   = "deel-test-app-tg"
  vpc_id              = var.app_vpc_id
  subnet_ids          = var.subnet_ids
  s3_bucket_id        = module.s3.bucket_id
  target_port         = 8080
  health_check_path   = "/health"
  tags                = local.common_tags
}

# ECS Module
module "ecs" {
  source                 = "./modules/ecs"
  name_prefix            = "deel-test-app"
  cluster_name           = "deel-test-app-cluster"
  service_name           = "deel-test-app"
  task_family            = "deel-test-app"
  container_name         = "deel-test-app"
  image_uri              = var.image_uri
  container_port         = 8080
  cpu                    = 256
  memory                 = 512
  desired_count          = 1
  vpc_id                 = var.app_vpc_id
  subnet_ids             = var.subnet_ids
  execution_role_arn     = module.iam.role_arn
  target_group_arn       = module.alb.target_group_arn
  alb_security_group_id  = module.alb.alb_security_group_id
  alb_listener_arn       = module.alb.alb_arn
  log_group_name         = "/ecs/deel-test-app"
  log_retention_days     = 365
  aws_region             = var.aws_region
  tags                   = local.common_tags
}