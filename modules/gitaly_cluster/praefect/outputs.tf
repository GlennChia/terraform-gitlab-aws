output "security_group_id" {
  description = "The id of the security group associated with the Praefect instance"
  value       = aws_security_group.this.id
}

output "prafect_loadbalancer_dns_name" {
  description = "The dns name associated with the Praefect loadbalancer"
  value       = aws_lb.this.dns_name
}