output "security_group_id" {
  description = "The id of the security group associated with the gitaly instance"
  value       = aws_security_group.this.id
}

output "private_ip" {
  description = "The internal ip associated with the gitlay instance. Used when configuring the GitLab instance"
  value       = aws_instance.this.private_ip
}