variable "subnet_ids" {
  description = "The list of private subnet ids"
  type        = list(string)
}

variable "ingress_security_group_id" {
  description = "The security group id of the security group that is allowed all ingress"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}