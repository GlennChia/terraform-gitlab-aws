/**
* # Gitaly Cluster Module
*
* Creates a HA Gitaly cluster with Praefect nodes behind a loadbalancer
*
* For dev, set `deletion_protection` to `false` and `skip_final_snapshot` to `true`
*/

module "database" {
  source = "./database"

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.subnet_ids
  ingress_security_group_ids = [module.praefect.security_group_id]
  rds_name                   = var.rds_name
  username                   = var.rds_username
  password                   = var.rds_password
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
}

module "praefect" {
  source = "./praefect"

  vpc_id                               = var.vpc_id
  vpc_cidr                             = var.vpc_cidr
  subnet_ids                           = var.subnet_ids
  rds_address                          = module.database.rds_address
  rds_name                             = var.rds_name
  rds_username                         = var.rds_username
  rds_password                         = var.rds_password
  praefect_sql_password                = var.praefect_sql_password
  praefect_external_token              = var.praefect_external_token
  praefect_internal_token              = var.praefect_internal_token
  private_ips_gitaly                   = var.private_ips_gitaly
  iam_instance_profile                 = var.iam_instance_profile
  private_ips_praefect                 = var.private_ips_praefect
  praefect_key_name                    = var.praefect_key_name
  ssh_ingress_security_group_id        = var.ssh_ingress_security_group_id
  custom_ingress_security_group_id     = var.custom_ingress_security_group_id
  prometheus_ingress_security_group_id = var.prometheus_ingress_security_group_id
}

module "gitaly" {
  source = "./gitaly"

  vpc_id                               = var.vpc_id
  subnet_ids                           = var.subnet_ids
  praefect_internal_token              = var.praefect_internal_token
  secret_token                         = var.secret_token
  visibility                           = var.visibility
  lb_dns_name                          = var.lb_dns_name
  instance_dns_name                    = var.instance_dns_name
  iam_instance_profile                 = var.iam_instance_profile
  private_ips_gitaly                   = var.private_ips_gitaly
  gitaly_key_name                      = var.gitaly_key_name
  ssh_ingress_security_group_id        = var.ssh_ingress_security_group_id
  custom_ingress_security_group_id     = module.praefect.security_group_id
  prometheus_ingress_security_group_id = var.prometheus_ingress_security_group_id
}