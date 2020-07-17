output "bastion_ip" {
  description = "The elastic ip associated with the Bastion instance"
  value       = aws_eip.this.public_ip
}