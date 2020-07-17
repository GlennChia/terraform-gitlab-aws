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