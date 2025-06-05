variable "project_name" {
  type        = string
  description = "プロジェクト名（タグやリソース命名で使用）"
}

variable "cidr_block" {
  type        = string
  description = "VPC の CIDR ブロック"
}

variable "public_subnet_cidr" {
  type        = string
  description = "パブリックサブネットの CIDR ブロック"
}

variable "public_subnet_az" {
  type        = string
  description = "パブリックサブネットを配置する AZ (例: ap-northeast-1a)"
}
