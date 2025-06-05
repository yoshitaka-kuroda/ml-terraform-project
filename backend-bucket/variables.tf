variable "aws_region" {
  type        = string
  description = "AWSのリージョン"
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI で設定したプロファイル名"
  default     = "default"
}

variable "bucket_name" {
  type        = string
  description = "バックエンド用 S3 バケット名（一意にすること）"
  default     = "yoshitaka-terraform-state-bucket"  # 任意の一意な名前に置き換えてOK
}
