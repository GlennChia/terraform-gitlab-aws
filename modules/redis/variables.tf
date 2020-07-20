variable "subnet_ids" {
  description = "The list of public subnet ids"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones to deploy the subnets in"
  type        = list(string)
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "replication_group_id" {
  description = "The replication group identifier"
  type        = string
  default     = "gitlab-redis"
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.medium"
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate with this cache cluster"
  type        = string
  default     = "default.redis5.0"
}

variable "engine_version" {
  description = "Version number of the cache engine to be used"
  type        = string
  default     = "5.0.6"
}

variable "ingress_security_group_ids" {
  description = "The list security group id of the security group that is allowed ingress"
  type        = list(string)
}