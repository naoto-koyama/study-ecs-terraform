locals {
  project_name = "ecs-project"
  environment  = "dev"
  prefix       = "${local.project_name}-${local.environment}"

  # 開発環境固有の設定
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  desired_count        = 1                 # 開発環境は1つのコンテナ
  enable_nat_gateway   = false             # NATゲートウェイなし
  assign_public_ip     = true              # パブリックIPを割り当て
  log_retention_days   = 7                 # ログ保持期間7日
}

# AWSプロバイダーの設定
provider "aws" {
  region = "ap-northeast-1"  # 東京リージョンを使用することを指定

  default_tags {
    tags = {
      Environment = "dev"
      Project     = local.project_name
      Terraform   = "true"
    }
  }
}

# Terraformの基本設定
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWSプロバイダーの取得元
      version = "~> 5.0"         # AWSプロバイダーのバージョン指定
    }
  }
}

# networkモジュールの呼び出し
module "network" {
  source = "../../modules/network"

  environment          = local.environment
  vpc_cidr            = local.vpc_cidr
  azs                 = local.azs
  private_subnet_cidrs = local.enable_nat_gateway ? local.private_subnet_cidrs : []  # NAT Gatewayが無効な場合はプライベートサブネットを作成しない
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
  # NAT Gatewayが無効な場合はパブリックサブネットを使用
  private_subnet_ids          = local.enable_nat_gateway ? module.network.private_subnet_ids : module.network.public_subnet_ids
  ecs_tasks_security_group_id = module.security.ecs_tasks_security_group_id
  target_group_arn            = module.alb.target_group_arn
  desired_count               = local.desired_count
  assign_public_ip            = local.assign_public_ip
  log_retention_days          = local.log_retention_days
}
