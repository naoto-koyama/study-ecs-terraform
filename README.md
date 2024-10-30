# ECS Terraform Project

## 概要
Terraformを使用してAWS ECS（Fargate）環境を構築するためのコード

## 前提条件
- Terraform >= 1.0
- AWS CLIのインストールと設定
- AWS アカウント

## ディレクトリ構成
- `environments/`: 環境ごとの設定
    - `dev/`: 開発環境
    - `prod/`: 本番環境
- `modules/`: 再利用可能なTerraformモジュール
    - `network/`: VPC、サブネットなどのネットワークリソース
    - `ecs/`: ECSクラスター、タスク定義、サービス
    - `alb/`: Application Load Balancer
    - `security/`: セキュリティグループ、IAMロール

## 環境構築手順
- `environments/`ディレクトリに環境ごとの設定ファイルを作成
- `terraform init`で初期化
```bash
cd environments/dev
docker compose -f ../../docker-compose.yml run --rm terraform init
```

- planを実行
```bash
docker compose -f ../../docker-compose.yml run --rm terraform plan
```

- applyを実行
```bash
docker compose -f ../../docker-compose.yml run --rm terraform apply
```
