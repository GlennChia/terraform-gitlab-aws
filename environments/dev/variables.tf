variable "region" {
  description = "The region to deploy the resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "VPC Cidr Range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidrsubnet_newbits" {
  description = "Second argument to cidrsubnet function"
  type        = number
  default     = 8
}

variable "bastion_instance_type" {
  description = "The Bastion instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "The Bastion key name of a key that has already been created"
  type        = string
}

variable "whitelist_ssh_ip" {
  description = "The list of IPs that can SSH into the Bastion"
  type        = list(string)
}

variable "whitelist_ip" {
  description = "The list of IPs that can reach the load balancer via HTTP or HTTPs"
  type        = list(string)
}

variable "access_log_bucket_acl" {
  description = "The canned ACL to apply. Options are `private`, `public-read`, `public-read-write` among others"
  type        = string
  default     = "private"
}

variable "force_destroy" {
  description = "Indicates that all objects should be deleted from the bucket so that it can be destroyed without error"
  type        = bool
  default     = true
}