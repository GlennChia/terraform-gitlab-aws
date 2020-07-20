output "bastion_ip" {
  description = "The elastic ip associated with the bastion instance"
  value       = module.bastion.public_ip
}