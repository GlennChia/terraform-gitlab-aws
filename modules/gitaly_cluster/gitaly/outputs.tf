output "security_group_id" {
  description = "The id of the security group associated with the Gitaly instance"
  value       = aws_security_group.this.id
}