terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# S3 バケット本体
resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name
  acl    = "private"         # 誰でも読めないプライベートにする

  # S3 のバージョニングを有効化
  versioning {
    enabled = true
  }

  tags = {
    Name        = var.bucket_name
    Environment = "terraform-backend"
  }
}

# パブリックアクセスをすべてブロックする設定
resource "aws_s3_bucket_public_access_block" "tfstate_block" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
