output "primary_address" {
  description = "The address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}