output "bastion_ip" {
  description = "The elastic ip associated with the bastion instance"
  value       = module.bastion.public_ip
}

output "elb_dns_name" {
  description = "The endpoint associated with the elb"
  value       = module.loadbalancer.dns_name
}

output "gitlab_instance_public_dns" {
  description = "The public DNS of the instance"
  value       = module.gitlab_image.public_dns
}

output "gitaly_private_ip" {
  description = "The private ip associated with the gitlay instance. Used when configuring the GitLab instance"
  value       = module.gitaly.private_ip
}

output "eks_endpoint" {
  description = "The endpoint for your Kubernetes API server"
  value       = module.eks.endpoint
}