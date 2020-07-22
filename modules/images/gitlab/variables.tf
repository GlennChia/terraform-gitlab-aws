variable "rds_address" {
  description = "The hostname of the RDS instance which does not have `port`"
  type        = string
}

variable "redis_address" {
  description = "The address of the endpoint for the primary node in the elasticache replication group, if the cluster mode is disabled."
  type        = string
}

variable "rds_password" {
  description = "Password for the master DB user"
  type        = string
}

variable "dns_name" {
  description = "Domain that users will reach to access GitLab"
  type        = string
}

variable "visibility" {
  description = "Determines if the instance is private (behind a loadbalancer) or public (using its own dns)"
  type        = string
  default     = "private"
}

variable "region" {
  description = "The region to deploy the resources in"
  type        = string
}

variable "gitlab_artifacts_bucket_name" {
  description = "The artifact bucket's name"
  type        = string
  default     = "gl-aws-artifacts"
}

variable "gitlab_lfs_bucket_name" {
  description = "The large file storage objects bucket's name"
  type        = string
  default     = "gl-aws-lfs-objects"
}

variable "gitlab_uploads_bucket_name" {
  description = "The user uploads bucket's name"
  type        = string
  default     = "gl-aws-uploads"
}

variable "gitlab_packages_bucket_name" {
  description = "The packages bucket's name"
  type        = string
  default     = "gl-aws-packages"
}

variable "instance_type" {
  description = "Instance type for the GitLab instance"
  type        = string
  default     = "c5.xlarge"
}

variable "security_group_ids" {
  description = "The list security group ids attached to the GitLab instance"
  type        = list(string)
}

variable "subnet_id" {
  description = "Private or public subnet id depending on requirements"
  type        = string
}

variable "gitlab_key_name" {
  description = "The key name of a key that has already been created that will be attached to the GitLab instance"
  type        = string
}