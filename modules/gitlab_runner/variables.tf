variable "instance_type" {
  description = "Instance type for the GitLab runner"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet id"
  type        = string
}

variable "key_name" {
  description = "The key name of a key that has already been created that will be attached to the GitLab Runner instance"
  type        = string
}

variable "bastion_security_group_id" {
  description = "The id of the bastion security group"
  type        = string
}

variable "http_ingress_security_group_id" {
  description = "The id of the security group allows to hit HTTP endpoint"
  type        = string
}