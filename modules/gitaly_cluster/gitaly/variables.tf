variable "praefect_internal_token" {
  description = "Token needed by to communicate with the Gitaly cluster"
  type        = string
}

variable "secret_token" {
  description = "The token for authentication callbacks from GitLab Shell to the GitLab internal API"
  type        = string
}

variable "visibility" {
  description = "Determines if the instance is private (behind a loadbalancer) or public (using its own dns)"
  type        = string
  default     = "private"
}

variable "lb_dns_name" {
  description = "Domain that users will reach to access GitLab if using a load balancer"
  type        = string
}

variable "instance_dns_name" {
  description = "Domain that users will reach to access GitLab if using a public instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the Gitaly instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Gitaly instance"
  type        = string
  default     = "c5.xlarge"
}

variable "subnet_ids" {
  description = "Private subnet ids for clusters"
  type        = list(string)
}

variable "private_ips_gitaly" {
  description = "Assigned private ips to gitaly instances "
  type        = list(string)
}

variable "gitaly_key_name" {
  description = "The key name of a key that has already been created that will be attached to the gitaly instance"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "ssh_ingress_security_group_id" {
  description = "The id of the security group allowed to ssh"
  type        = string
  default     = ""
}

variable "custom_ingress_security_group_id" {
  description = "The id of the security group allowed to communicate with Gitaly"
  type        = string
  default     = ""
}

variable "prometheus_ingress_security_group_id" {
  description = "The id of the security group allowed to hit prometheus endpoint"
  type        = string
  default     = ""
}