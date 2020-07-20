/**
* # Dev environment
*
* Link for manual installation: [Installing GitLab on Amazon Web Services (AWS)](https://docs.gitlab.com/ee/install/aws/)
*/

terraform {
  required_version = ">= 0.12.28"
  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_availability_zones" "available" {}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "network" {
  source = "../../modules/network"

  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  cidrsubnet_newbits = var.cidrsubnet_newbits
}

module "bastion" {
  source = "../../modules/bastion"

  region           = var.region
  instance_type    = var.bastion_instance_type
  bastion_key_name = var.bastion_key_name
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.this_subnet_public_ids
  whitelist_ssh_ip = var.whitelist_ssh_ip
}

module "storage" {
  source = "../../modules/storage"

  acl           = var.access_log_bucket_acl
  force_destroy = var.force_destroy
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.this_subnet_public_ids
  elb_log_s3_bucket_id      = module.storage.elb_log_s3_bucket_id
  whitelist_ip              = var.whitelist_ip
  bastion_security_group_id = module.bastion.security_group_id
}