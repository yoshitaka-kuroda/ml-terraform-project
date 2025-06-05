###############################################################################
# 共通変数
###############################################################################

variable "project_name" {
  type        = string
  description = "プロジェクト名"
  default     = "ml-portfolio"
}

variable "aws_region" {
  type        = string
  description = "AWS リージョン"
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI で設定したプロファイル名"
  default     = "default"
}

###############################################################################
# VPC 用変数
###############################################################################

variable "vpc_cidr" {
  type        = string
  description = "VPC の CIDR ブロック"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "パブリックサブネットの CIDR ブロック"
  default     = "10.0.1.0/24"
}

variable "public_subnet_az" {
  type        = string
  description = "パブリックサブネットを配置する AZ (例: ap-northeast-1a)"
  default     = "ap-northeast-1a"
}

###############################################################################
# S3 用変数
###############################################################################

variable "data_bucket_name" {
  type        = string
  description = "データ保存用 S3 バケット名（一意にすること）"
  default     = "yoshitaka-ml-portfolio-data-bucket-apne1"
}

###############################################################################
# SageMaker Notebook 用変数
###############################################################################

variable "notebook_instance_type" {
  type        = string
  description = "Notebook インスタンスのタイプ"
  default     = "ml.t2.medium"
}

###############################################################################
# SageMaker Training 用変数
###############################################################################

variable "training_image" {
  type        = string
  description = "トレーニング用 Docker イメージ URI"
  default     = "683313688378.dkr.ecr.ap-northeast-1.amazonaws.com/sagemaker-scikit-learn:0.20.0-cpu-py3"
}

variable "training_instance_count" {
  type        = number
  description = "トレーニングジョブのインスタンス数"
  default     = 1
}

variable "training_instance_type" {
  type        = string
  description = "トレーニング用インスタンスタイプ"
  default     = "ml.t2.medium"
}

variable "training_volume_size" {
  type        = number
  description = "トレーニング用 EBS サイズ (GB)"
  default     = 20
}

variable "training_max_run_seconds" {
  type        = number
  description = "トレーニングジョブの最大実行時間 (秒)"
  default     = 3600
}

###############################################################################
# SageMaker Endpoint 用変数
###############################################################################

variable "endpoint_instance_count" {
  type        = number
  description = "エンドポイント用インスタンス数"
  default     = 1
}

variable "endpoint_instance_type" {
  type        = string
  description = "エンドポイント用インスタンスタイプ"
  default     = "ml.t2.medium"
}
