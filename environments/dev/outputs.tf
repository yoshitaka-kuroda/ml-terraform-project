output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "作成された VPC の ID"
}

output "notebook_url" {
  value       = module.sagemaker.notebook_instance_url
  description = "SageMaker Notebook の URL"
}

# 以下はまだ Module 出力が存在しないためコメントアウトする
# output "training_job_name" {
#   value       = module.sagemaker.training_job_name
#   description = "実行されたトレーニングジョブの名前"
# }

# output "endpoint_name" {
#   value       = module.sagemaker.endpoint_name
#   description = "作成されたエンドポイントの名前"
# }
