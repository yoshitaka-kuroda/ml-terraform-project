variable "project_name" {
  type        = string
  description = "プロジェクト名（リソース命名に使用）"
}

variable "bucket_name" {
  type        = string
  description = "S3 バケット名（一意にすること）"
}
