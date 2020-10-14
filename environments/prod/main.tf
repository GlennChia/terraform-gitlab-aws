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
  region             = var.region
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

  load_balancer_bucket = var.load_balancer_bucket
  acl                  = var.access_log_bucket_acl
  force_destroy        = var.force_destroy
  vpce_id              = module.network.vpce_id
  gitlab_buckets = [
    var.gitlab_artifacts_bucket_name, var.gitlab_external_diffs_bucket_name,
    var.gitlab_lfs_bucket_name, var.gitlab_uploads_bucket_name,
    var.gitlab_packages_bucket_name, var.gitlab_dependency_proxy_bucket_name,
    var.gitlab_terraform_state_bucket_name, var.gitlab_aws_runner_cache
  ]
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  vpc_id                          = module.network.vpc_id
  subnet_ids                      = module.network.this_subnet_public_ids
  elb_log_s3_bucket_id            = module.storage.elb_log_s3_bucket_id
  whitelist_ip                    = var.whitelist_ip
  bastion_security_group_id       = module.bastion.security_group_id
  http_ingress_security_group_ids = [module.eks.security_group_id, module.gitaly_cluster.gitaly_security_group_id]
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  iam_instance_profile             = module.gitlab_image.iam_instance_profile
  image_id                         = module.gitlab_image.image_id
  instance_type                    = var.gitlab_instance_type
  launch_configuration_name_prefix = var.launch_configuration_name_prefix
  security_groups                  = [module.gitlab_image.security_group_id]
  subnet_ids                       = module.network.this_subnet_private_ids
  autoscaling_group_name           = var.autoscaling_group_name
  target_group_arns                = [module.loadbalancer.target_group_arn]
}

module "database" {
  source = "../../modules/database"

  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.this_subnet_private_ids
  ingress_security_group_ids = [module.gitlab_image.security_group_id]
  rds_name                   = var.rds_name_gitlab
  username                   = var.rds_username_gitlab
  password                   = var.rds_password_gitlab
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
}

module "redis" {
  source = "../../modules/redis"

  vpc_id                     = module.network.vpc_id
  availability_zones         = data.aws_availability_zones.available.names
  subnet_ids                 = module.network.this_subnet_private_ids
  ingress_security_group_ids = [module.gitlab_image.security_group_id]
}

module "gitlab_image" {
  source = "../../modules/images/gitlab"

  private_ip_gitlab                     = var.private_ip_gitlab
  rds_address                           = module.database.rds_address
  redis_address                         = module.redis.primary_address
  rds_name                              = var.rds_name_gitlab
  rds_username                          = var.rds_username_gitlab
  rds_password                          = var.rds_password_gitlab
  dns_name                              = module.loadbalancer.dns_name
  region                                = var.region
  gitlab_artifacts_bucket_name          = var.gitlab_artifacts_bucket_name
  gitlab_lfs_bucket_name                = var.gitlab_lfs_bucket_name
  gitlab_uploads_bucket_name            = var.gitlab_uploads_bucket_name
  gitlab_packages_bucket_name           = var.gitlab_packages_bucket_name
  gitlab_external_diffs_bucket_name     = var.gitlab_external_diffs_bucket_name
  gitlab_dependency_proxy_bucket_name   = var.gitlab_dependency_proxy_bucket_name
  gitlab_terraform_state_bucket_name    = var.gitlab_terraform_state_bucket_name
  gitaly_token                          = var.gitaly_token
  secret_token                          = var.secret_token
  gitaly_config                         = var.gitaly_config
  private_ips_gitaly                    = var.private_ips_gitaly
  private_ips_praefect                  = var.private_ips_praefect
  praefect_external_token               = var.praefect_external_token
  prafect_loadbalancer_dns_name         = module.gitaly_cluster.prafect_loadbalancer_dns_name
  vpc_id                                = module.network.vpc_id
  whitelist_ip                          = var.whitelist_ip
  ssh_ingress_security_group_ids        = [module.bastion.security_group_id]
  prometheus_ingress_security_group_ids = []
  http_ingress_security_group_ids       = [module.eks.security_group_id, module.gitaly_cluster.gitaly_security_group_id, module.loadbalancer.security_group_id]
  visibility                            = var.visibility
  subnet_id                             = module.network.this_subnet_public_ids[0]
  gitlab_key_name                       = var.gitlab_key_name
  grafana_password                      = var.grafana_password
}

module "iam" {
  source = "../../modules/iam"
}

module "gitaly_cluster" {
  source = "../../modules/gitaly_cluster"

  vpc_id                               = module.network.vpc_id
  vpc_cidr                             = var.vpc_cidr
  subnet_ids                           = module.network.this_subnet_private_ids
  ingress_security_group_ids           = []
  rds_name                             = var.rds_name_gitaly
  rds_username                         = var.rds_username_gitaly
  rds_password                         = var.rds_password_gitaly
  deletion_protection                  = var.deletion_protection
  skip_final_snapshot                  = var.skip_final_snapshot
  praefect_sql_password                = var.praefect_sql_password
  praefect_external_token              = var.praefect_external_token
  praefect_internal_token              = var.gitaly_token
  private_ips_gitaly                   = var.private_ips_gitaly
  private_ips_praefect                 = var.private_ips_praefect
  iam_instance_profile                 = module.iam.ssm_instance_profile
  praefect_key_name                    = var.praefect_key_name
  custom_ingress_security_group_id     = module.gitlab_image.security_group_id
  ssh_ingress_security_group_id        = module.bastion.security_group_id
  prometheus_ingress_security_group_id = module.gitlab_image.security_group_id
  secret_token                         = var.secret_token
  visibility                           = var.visibility
  lb_dns_name                          = module.loadbalancer.dns_name
  instance_dns_name                    = module.gitlab_image.public_dns
  gitaly_key_name                      = var.gitaly_key_name
}

module "eks" {
  source = "../../modules/eks"

  subnet_ids                = module.network.this_subnet_private_ids
  ingress_security_group_id = module.gitlab_image.security_group_id
  vpc_id                    = module.network.vpc_id
}