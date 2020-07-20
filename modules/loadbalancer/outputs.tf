output "security_group_id" {
  description = "The id of the security group associated with the load balancer"
  value       = aws_security_group.this.id
}

output "dns_name" {
  description = "The endpoint of the load balancer"
  value       = aws_elb.classic.dns_name
}
