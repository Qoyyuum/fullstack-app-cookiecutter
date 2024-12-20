terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
module "vpc" {
  source = "./modules/vpc"

  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  tags = var.common_tags
}

# ECS Cluster
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  container_insights = var.enable_container_insights
  tags              = var.common_tags
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  
  tags = var.common_tags
}

# Elasticache Redis
module "redis" {
  source = "./modules/redis"

  project_name = var.project_name
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  node_type = var.redis_node_type
  tags      = var.common_tags
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids

  certificate_arn = var.certificate_arn
  tags           = var.common_tags
}

# S3 Bucket for Assets
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  tags        = var.common_tags
}
