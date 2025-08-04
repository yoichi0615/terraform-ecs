provider "aws" {
  region = "ap-northeast-1"
}

# ------------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------------
module "vpc" {
  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  env        = var.env
}

module "public_subnet_1" {
  source                  = "../../modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  name                    = "${var.env}-public-subnet-1"
}

module "public_subnet_2" {
  source                  = "../../modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  name                    = "${var.env}-public-subnet-2"
}

module "private_subnet_1" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  name              = "${var.env}-private-subnet-1"
}

module "private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  name              = "${var.env}-private-subnet-2"
}

module "internet_gateway" {
  source = "../../modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  env    = var.env
}

module "nat_gateway_1" {
  source    = "../../modules/nat_gateway"
  subnet_id = module.public_subnet_1.subnet_id
  env       = var.env
}

# module "nat_gateway_2" {
#   source    = "../../modules/nat_gateway"
#   subnet_id = module.public_subnet_2.subnet_id
#   env       = var.env
# }

module "public_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.public_subnet_1.subnet_id
  gateway_id   = module.internet_gateway.internet_gateway_id
  name         = "${var.env}-public-route-table"
}

module "private_route_table_1" {
  source         = "../../modules/route_table"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.private_subnet_1.subnet_id
  nat_gateway_id = module.nat_gateway_1.nat_gateway_id
  name           = "${var.env}-private-route-table-1"
}

module "private_route_table_2" {
  source         = "../../modules/route_table"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.private_subnet_2.subnet_id
  nat_gateway_id = module.nat_gateway_1.nat_gateway_id
  name           = "${var.env}-private-route-table-2"
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------
module "lb_security_group" {
  source      = "../../modules/security_group"
  name        = "${var.env}-lb-sg"
  description = "Allow HTTP traffic to load balancer"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "ecs_service_security_group" {
  source      = "../../modules/security_group"
  name        = "${var.env}-ecs-service-sg"
  description = "Allow traffic from load balancer to ECS service"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [module.lb_security_group.security_group_id]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ------------------------------------------------------------------------------
# FRONTEND (S3, CloudFront, ACM, Route53)
# ------------------------------------------------------------------------------
variable "domain_name" {
  description = "The domain name for the website"
  type        = string
  default     = "tech-study-t.xyz"
}

module "s3_website_bucket" {
  source      = "../../modules/s3"
  bucket_name = var.domain_name
  env         = var.env
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "acm_certificate_cloudfront" {
  source      = "../../modules/acm"
  domain_name = var.domain_name
  providers = {
    aws = aws.us-east-1
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in module.acm_certificate_cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = module.route53_frontend_record.zone_id
}

resource "aws_acm_certificate_validation" "cloudfront_cert" {
  provider             = aws.us-east-1
  certificate_arn      = module.acm_certificate_cloudfront.acm_certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

module "cloudfront_distribution" {
  source              = "../../modules/cloudfront"
  domain_name         = var.domain_name
  origin_domain_name  = module.s3_website_bucket.s3_bucket_website_endpoint
  acm_certificate_arn = module.acm_certificate_cloudfront.acm_certificate_arn
  depends_on          = [aws_acm_certificate_validation.cloudfront_cert]
}

module "route53_frontend_record" {
  source    = "../../modules/route53"
  zone_name = var.domain_name
  records = {
    "" = {
      type = "A"
      alias = {
        name                   = module.cloudfront_distribution.cloudfront_distribution_domain_name
        zone_id                = module.cloudfront_distribution.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  }
}

# ------------------------------------------------------------------------------
# BACKEND (ALB, ECS Fargate)
# ------------------------------------------------------------------------------
module "ecr_repository" {
  source          = "../../modules/ecr"
  repository_name = "${var.env}-api-repository" # ECRリポジトリ名
}

module "alb" {
  source             = "../../modules/alb"
  name               = "${var.env}-api-lb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]
  security_group_ids = [module.lb_security_group.security_group_id]
}

module "ecs_cluster" {
  source = "../../modules/ecs_cluster"
  name   = "${var.env}-cluster"
}

module "ecs_task_definition" {
  source         = "../../modules/ecs_task_definition"
  family         = "${var.env}-api-task"
  container_name = "${var.env}-api-container"
  container_image = "${module.ecr_repository.repository_url}:latest" # ECRリポジトリのURLを使用
  container_port = 80
}

module "ecs_service" {
  source              = "../../modules/ecs_service"
  name                = "${var.env}-api-service"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  desired_count       = 2
  subnet_ids          = [module.private_subnet_1.subnet_id, module.private_subnet_2.subnet_id]
  security_group_ids  = [module.ecs_service_security_group.security_group_id]
  lb_target_group_arn = module.alb.lb_target_group_arn
  container_name      = module.ecs_task_definition.container_name
  container_port      = module.ecs_task_definition.container_port
}

# ------------------------------------------------------------------------------
# DATABASE (RDS)
# ------------------------------------------------------------------------------
module "secrets_manager_rds_password" {
  source      = "../../modules/secrets_manager"
  secret_name = "${var.env}/rds/pass"
}

module "rds_instance" {
  source             = "../../modules/rds"
  env                = var.env
  private_subnet_ids = [module.private_subnet_1.subnet_id, module.private_subnet_2.subnet_id]
  db_username        = "admin"
  db_password        = module.secrets_manager_rds_password.secret_string
}

# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------
output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront_distribution.cloudfront_distribution_domain_name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.lb_dns_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds_instance.db_instance_address
}
