variable "project_name" {
  type        = string
  description = "プロジェクト名（リソース命名に利用）"
}

variable "sagemaker_execution_role_arn" {
  type        = string
  description = "SageMaker 実行用 IAM ロールの ARN"
}

variable "public_subnet_id" {
  type        = string
  description = "SageMaker Notebook/Training 用のサブネット ID"
}

# Notebook
variable "notebook_instance_type" {
  type        = string
  description = "Notebook インスタンスのタイプ"
  default     = "ml.t2.medium"
}

# Training Job
variable "training_image" {
  type        = string
  description = "トレーニング用 Docker イメージ URI"
  default     = "683313688378.dkr.ecr.ap-northeast-1.amazonaws.com/sagemaker-scikit-learn:0.20.0-cpu-py3"
}

variable "training_data_s3_uri" {
  type        = string
  description = "トレーニングデータが格納された S3 URI"
}

variable "training_output_s3_uri" {
  type        = string
  description = "トレーニング出力先の S3 URI"
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
  description = "トレーニング用 EBS サイズ(GB)"
  default     = 20
}

variable "training_max_run_seconds" {
  type        = number
  description = "トレーニングジョブの最大実行時間(秒)"
  default     = 3600
}

# Endpoint
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
