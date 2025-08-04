terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "prd/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
