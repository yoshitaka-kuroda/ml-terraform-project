output "notebook_instance_url" {
  value       = aws_sagemaker_notebook_instance.this.url
  description = "作成された Notebook インスタンスへの URL"
}

# 以下の出力はコメントアウトまたは削除しておく
# output "training_job_name" {
#   value       = aws_sagemaker_training_job.this.training_job_name
#   description = "実行されたトレーニングジョブの名前"
# }
#
# output "endpoint_name" {
#   value       = aws_sagemaker_endpoint.this.name
#   description = "作成されたエンドポイントの名前"
# }