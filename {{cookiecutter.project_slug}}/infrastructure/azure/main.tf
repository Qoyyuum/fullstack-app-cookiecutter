terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
module "resource_group" {
  source = "./modules/resource_group"

  name     = "${var.project_name}-rg"
  location = var.location
  tags     = var.common_tags
}

# Virtual Network
module "vnet" {
  source = "./modules/vnet"

  name                = "${var.project_name}-vnet"
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  subnets            = var.subnets
  
  tags = var.common_tags
}

# AKS Cluster
module "aks" {
  source = "./modules/aks"

  name                = "${var.project_name}-aks"
  resource_group_name = module.resource_group.name
  dns_prefix         = "${var.project_name}-k8s"
  
  default_node_pool  = var.default_node_pool
  additional_node_pools = var.additional_node_pools
  
  tags = var.common_tags
}

# Azure Database for PostgreSQL
module "postgresql" {
  source = "./modules/postgresql"

  name                = "${var.project_name}-db"
  resource_group_name = module.resource_group.name
  sku_name           = var.db_sku
  storage_mb         = var.db_storage_mb
  
  tags = var.common_tags
}

# Azure Cache for Redis
module "redis" {
  source = "./modules/redis"

  name                = "${var.project_name}-redis"
  resource_group_name = module.resource_group.name
  capacity           = var.redis_capacity
  family             = var.redis_family
  sku_name           = var.redis_sku
  
  tags = var.common_tags
}

# Application Gateway
module "app_gateway" {
  source = "./modules/app_gateway"

  name                = "${var.project_name}-appgw"
  resource_group_name = module.resource_group.name
  virtual_network_name = module.vnet.name
  subnet_name         = "appgw-subnet"
  
  tags = var.common_tags
}

# Storage Account
module "storage" {
  source = "./modules/storage"

  name                = "${var.project_name}storage"
  resource_group_name = module.resource_group.name
  account_tier        = "Standard"
  account_replication_type = "LRS"
  
  tags = var.common_tags
}
