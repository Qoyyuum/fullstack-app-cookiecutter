terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
module "vpc" {
  source = "./modules/vpc"

  project_id   = var.project_id
  network_name = "${var.project_name}-network"
  subnets      = var.subnets

  tags = var.common_tags
}

# GKE Cluster
module "gke" {
  source = "./modules/gke"

  project_id    = var.project_id
  cluster_name  = "${var.project_name}-cluster"
  network       = module.vpc.network_name
  subnetwork    = module.vpc.subnet_names[0]
  node_pools    = var.node_pools
  
  tags = var.common_tags
}

# Cloud SQL
module "cloudsql" {
  source = "./modules/cloudsql"

  project_id      = var.project_id
  instance_name   = "${var.project_name}-db"
  database_version = var.database_version
  tier            = var.database_tier
  
  tags = var.common_tags
}

# Redis Instance
module "redis" {
  source = "./modules/redis"

  project_id     = var.project_id
  instance_name  = "${var.project_name}-redis"
  memory_size_gb = var.redis_memory_size_gb
  
  tags = var.common_tags
}

# Load Balancer
module "lb" {
  source = "./modules/lb"

  project_id = var.project_id
  name      = "${var.project_name}-lb"
  network   = module.vpc.network_name
  
  tags = var.common_tags
}

# Cloud Storage
module "storage" {
  source = "./modules/storage"

  project_id   = var.project_id
  bucket_name  = "${var.project_name}-assets"
  location     = var.region
  
  tags = var.common_tags
}
