output "bastion_ip" {
  description = "The elastic ip associated with the bastion instance"
  value       = module.bastion.bastion_ip
}

output "elb_endpoint" {
  description = "The endpoint associated with the elb"
  value       = module.loadbalancer.endpoint
}