# output "id" {
#   description = "The id of the created GitLab AMI"
#   value       = aws_ami_from_instance.this.id
# }

output "public_dns" {
  description = "The public DNS of the instance"
  value       = aws_instance.this.public_dns
}

output "security_group_id" {
  description = "The id of the security group associated with the GitLab instance"
  value       = aws_security_group.this.id
}