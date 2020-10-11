output "prafect_loadbalancer_dns_name" {
  description = "The dns name associated with the Praefect loadbalancer"
  value       = module.praefect.prafect_loadbalancer_dns_name
}