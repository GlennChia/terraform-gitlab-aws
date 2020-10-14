output "security_group_id" {
  description = "The id of the security group associated with the load balancer"
  value       = aws_security_group.this.id
}

output "dns_name" {
  description = "The endpoint of the load balancer"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.this.arn
}