output "prafect_loadbalancer_dns_name" {
  description = "The dns name associated with the Praefect loadbalancer"
  value       = module.praefect.prafect_loadbalancer_dns_name
}

output "gitaly_security_group_id" {
  description = "The id of the security group associated with the Gitaly instance"
  value       = module.gitaly.security_group_id
}