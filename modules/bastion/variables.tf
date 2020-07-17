variable "region" {
  description = "The region to deploy the resources in"
  type        = string
}

variable "instance_type" {
  description = "The Bastion instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "The key name of a key that has already been created that will be attached to the Bastion instance"
  type        = string
}

variable "subnet_ids" {
  description = "The list of public subnet ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "whitelist_ssh_ip" {
  description = "The list of IPs that can SSH into the Bastion"
  type        = list(string)
}