output "data_bucket_arn" {
  value       = aws_s3_bucket.data_bucket.arn
  description = "データ用 S3 バケットの ARN"
}

output "data_bucket_name" {
  value       = aws_s3_bucket.data_bucket.id
  description = "データ用 S3 バケット名"
}