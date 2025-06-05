resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true  # バケット削除時にオブジェクトも一括削除
  tags = {
    Name = "${var.project_name}-data"
  }
}