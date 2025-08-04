module "network" {
  source = "../../modules/network"
  env    = var.env
}

module "cloudfront_s3" {
  source      = "../../modules/cloudfront_s3"
  domain_name = "your-domain.com" # Replace with your domain name
  env         = var.env
}

module "ecs_service" {
  source             = "../../modules/ecs_service"
  env                = var.env
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}

module "rds" {
  source             = "../../modules/rds"
  env                = var.env
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  db_username        = "admin"
  db_password        = "password"
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.ecs_service.lb_dns_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.cloudfront_s3.s3_bucket_name
}

output "db_instance_address" {
  description = "The address of the DB instance"
  value       = module.rds.db_instance_address
}