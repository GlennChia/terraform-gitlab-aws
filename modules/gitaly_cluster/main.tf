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
  ingress_security_group_ids = []
  rds_name                   = var.rds_name
  username                   = var.rds_username
  password                   = var.rds_password
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
}