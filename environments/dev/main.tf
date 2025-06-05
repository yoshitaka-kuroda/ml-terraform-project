terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"    # 5.x 系の最新版を使うように上げる
    }
  }
  # backend は必要に応じて backend.tf を使って設定
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

###############################################################################
# VPC モジュール呼び出し
###############################################################################
module "vpc" {
  source              = "../../modules/vpc"
  project_name        = var.project_name
  cidr_block          = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  public_subnet_az    = var.public_subnet_az
}

###############################################################################
# IAM モジュール呼び出し
###############################################################################
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

###############################################################################
# S3 モジュール呼び出し
###############################################################################
module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  bucket_name  = var.data_bucket_name
}

###############################################################################
# SageMaker モジュール呼び出し
###############################################################################
module "sagemaker" {
  source                      = "../../modules/sagemaker"
  project_name                = var.project_name
  sagemaker_execution_role_arn = module.iam.sagemaker_execution_role_arn
  public_subnet_id            = module.vpc.public_subnet_id

  # Notebook
  notebook_instance_type      = var.notebook_instance_type

  # Training
  training_image              = var.training_image
  training_data_s3_uri        = "s3://${module.s3.data_bucket_name}/training/your_dataset.csv"
  training_output_s3_uri      = "s3://${module.s3.data_bucket_name}/output/"
  training_instance_count     = var.training_instance_count
  training_instance_type      = var.training_instance_type
  training_volume_size        = var.training_volume_size
  training_max_run_seconds    = var.training_max_run_seconds

  # Endpoint
  endpoint_instance_count     = var.endpoint_instance_count
  endpoint_instance_type      = var.endpoint_instance_type
}