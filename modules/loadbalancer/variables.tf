variable "elb_log_s3_bucket_id" {
  description = "The bucket id of the bucket meant for elb logs"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The list of public subnet ids"
  type        = list(string)
}

variable "whitelist_ip" {
  description = "Whitelist of IPs that can reach the load balancer via HTTP or HTTPs"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "The id of the bastion security group"
  type        = string
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "http_ingress_security_group_ids" {
  description = "The ids of the security groups allows to hit HTTP endpoint"
  type        = list(string)
}