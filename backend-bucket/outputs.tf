output "bucket_arn" {
  value       = aws_s3_bucket.tfstate.arn
  description = "作成したバックエンド用 S3 バケットの ARN"
}
