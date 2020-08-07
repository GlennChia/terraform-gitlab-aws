output "endpoint" {
  description = "The endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.this.endpoint
}