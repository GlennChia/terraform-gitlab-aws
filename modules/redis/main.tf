/**
* # Redis Module
*
* Creates a Redis Instance with multi-az and automatic failover
*
* ## Issues and fixes
*
* <b>Issue 1: Redis is not deployed as multi-az</b>
* 
* This is a feature that has not been added to Terraform yet. Updates can be found [here](https://github.com/terraform-providers/terraform-provider-aws/issues/13706)
*
* ## Additional details
*
* If we want to create a single instance of Redis, use the following block
*
* ```
* resource "aws_elasticache_cluster" "gitlab-redis" {
*   cluster_id           = "gitlab-redis"
*   engine               = "redis"
*   node_type            = var.node_type
*   num_cache_nodes      = 1
*   parameter_group_name = var.parameter_group_name
*   subnet_group_name    = aws_elasticache_subnet_group.this.name
*   security_group_ids   = [aws_security_group.this.id]
*   engine_version       = "5.0.6"
*   port                 = 6379
* }
* ```
*/
resource "aws_elasticache_subnet_group" "this" {
  name       = "gitlab-redis-group"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.replication_group_id
  replication_group_description = "Redis for gitlab deployment"
  number_cache_clusters         = length(var.availability_zones)
  node_type                     = var.node_type
  automatic_failover_enabled    = true
  availability_zones            = var.availability_zones
  engine                        = "redis"
  engine_version                = var.engine_version
  parameter_group_name          = var.parameter_group_name
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.this.id]
  port                          = 6379
}

resource "aws_security_group" "this" {
  name        = "gitlab-redis-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitlab redis"

  ingress {
    description     = "Allow ingress thru the ELB"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  tags = {
    Name = "gitlab-redis-sec-group"
  }
}