output "endpoint" {
  description = "The endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.this.endpoint
}

output "security_group_id" {
  description = "The id of the default security group associated with the eks cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}