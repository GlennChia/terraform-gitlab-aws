variable "gitaly_token" {
  description = "The token authenticate gRPC requests to Gitaly"
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

variable "instance_dns_name" {
  description = "Domain that users will reach to access GitLab if using a public instance"
  type        = string
}

variable "lb_dns_name" {
  description = "Domain that users will reach to access GitLab if using a load balancer"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Gitaly instance"
  type        = string
  default     = "c5.xlarge"
}

variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the Gitaly instance"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet id"
  type        = string
}

variable "private_ip" {
  description = "Assigned private ip to gitaly instance"
  type        = string
}

variable "key_name" {
  description = "The key name of a key that has already been created that will be attached to the Gitaly instance"
  type        = string
}

variable "bastion_security_group_id" {
  description = "The id of the bastion security group"
  type        = string
}

variable "custom_ingress_security_group_id" {
  description = "The security group id of the security group that is allowed ingress on custom port 8075"
  type        = string
}

variable "volume_type" {
  description = "The type of volume. Can be standard, gp2, io1, sc1 or st1"
  type        = string
  default     = "io1"
}

variable "iops" {
  description = "The amount of provisioned IOPS. You can provision up to 50 IOPS per GiB."
  type        = number
  default     = 1000
}

variable "volume_size" {
  description = "The size of the volume in gibibytes (GiB)"
  type        = number
  default     = 20
}

variable "delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination"
  type        = bool
  default     = true
}
