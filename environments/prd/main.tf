terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

locals {
  project_name = "ecs-project"
  environment  = "prd"
  prefix       = "${local.project_name}-${local.environment}"

  # 本番環境固有の設定
  vpc_cidr             = "10.1.0.0/16"     # 本番環境は異なるCIDR
  azs                  = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidrs  = ["10.1.11.0/24", "10.1.12.0/24"]
  container_count      = 2                  # 本番環境は2つのコンテナ
  enable_nat_gateway   = true              # NATゲートウェイあり
  assign_public_ip     = false             # パブリックIP割り当てなし
  log_retention_days   = 30                # ログ保持期間30日
}

module "network" {
  source = "../../modules/network"

  environment          = local.environment
  vpc_cidr            = local.vpc_cidr
  azs                 = local.azs
  private_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs  = local.public_subnet_cidrs
  enable_nat_gateway   = local.enable_nat_gateway
}

module "security" {
  source = "../../modules/security"

  prefix = local.prefix
  vpc_id = module.network.vpc_id
}

module "alb" {
  source = "../../modules/alb"

  prefix               = local.prefix
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}

module "ecs" {
  source = "../../modules/ecs"

  prefix                      = local.prefix
  private_subnet_ids          = module.network.private_subnet_ids
  ecs_tasks_security_group_id = module.security.ecs_tasks_security_group_id
  target_group_arn            = module.alb.target_group_arn
  container_count             = local.container_count
  assign_public_ip            = local.assign_public_ip
  log_retention_days          = local.log_retention_days
}
