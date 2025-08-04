terraform {
  backend "s3" {
    bucket = "ecs-terraform-state-bucket-20250804"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
