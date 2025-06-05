terraform {
  backend "s3" {
    bucket = "yoshitaka-terraform-state-bucket"
    key    = "ml-terraform-project/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}