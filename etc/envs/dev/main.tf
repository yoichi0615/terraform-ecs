provider "aws" {
    region = "ap-northeast-1"
}

module "vpc" {
    source = "../../../modules/vpc"

    cidr_block = "10.0.0.0/16"
    env = var.env
}

module "public_subnet_1" {
  source = "../../modules/subnet/"

  vpc_id = module.vpc.vpc_id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  name = "${var.env}-public-subnet-1"
}

module "public_subnet_2" {
  source = "../../modules/subnet/"

  vpc_id = module.vpc.vpc_id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true
  name = "${var.env}-public-subnet-2"
}

module "private_subnet_1" {
  source = "../../modules/subnet/"

  vpc_id = module.vpc.vpc_id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  name = "${var.env}-private-subnet-1"
}

module "private_subnet_2" {
  source = "../../modules/subnet/"

  vpc_id = module.vpc.vpc_id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true
  name = "${var.env}-private-subnet-2"
}

module "internet_gateway" {
  source = "../../modules/internet_gateway/"

  vpc_id = module.vpc.vpc_id
  env = var.env
}



