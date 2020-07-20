output "bastion_ip" {
  description = "The elastic ip associated with the bastion instance"
  value       = module.bastion.public_ip
}

output "elb_dns_name" {
  description = "The endpoint associated with the elb"
  value       = module.loadbalancer.dns_name
}