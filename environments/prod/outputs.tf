output "bastion_ip" {
  description = "The elastic ip associated with the bastion instance"
  value       = module.bastion.public_ip
}

output "gitlab_instance_public_dns" {
  description = "The public DNS of the instance"
  value       = module.gitlab_image.public_dns
}

output "eks_endpoint" {
  description = "The endpoint for your Kubernetes API server"
  value       = module.eks.endpoint
}

output "gitlab_loadbalancer_dns_name" {
  description = "The endpoint of the GitLab load balancer"
  value       = module.loadbalancer.dns_name
}
