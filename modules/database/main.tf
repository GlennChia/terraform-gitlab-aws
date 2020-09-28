/**
* # RDS Module
*
* Creates an RDS Instance with a security group that allows ingress from a specified security group
*
* For dev, set `deletion_protection` to `false` and `skip_final_snapshot` to `true`
*/

resource "aws_db_subnet_group" "this" {
  name       = "gitlab-rds-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "gitlab-rds-group"
  }
}

resource "aws_db_instance" "this" {
  name                       = var.rds_name
  allocated_storage          = var.allocated_storage
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_retention_period    = var.backup_retention_period
  db_subnet_group_name       = aws_db_subnet_group.this.name
  deletion_protection        = var.deletion_protection
  engine                     = var.engine
  engine_version             = var.engine_version
  final_snapshot_identifier  = "gitlabhqproduction"
  identifier                 = "gitlab-db-ha"
  instance_class             = var.instance_class
  multi_az                   = var.multi_az
  storage_type               = var.storage_type
  username                   = var.username
  password                   = var.password
  publicly_accessible        = var.publicly_accessible
  skip_final_snapshot        = var.skip_final_snapshot
  vpc_security_group_ids     = [aws_security_group.this.id]
}

resource "aws_security_group" "this" {
  name        = "gitlab-rds-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitlab RDS"

  ingress {
    description     = "Allow ingress thru the ELB"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  tags = {
    Name = "gitlab-rds-sec-group"
  }
}