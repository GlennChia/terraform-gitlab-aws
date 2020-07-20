output "public_ip" {
  description = "The elastic ip associated with the Bastion instance"
  value       = aws_eip.this.public_ip
}

output "security_group_id" {
  description = "The id of the bastion security group"
  value       = aws_security_group.this.id
}