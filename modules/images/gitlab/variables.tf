variable "private_ip_gitlab" {
  description = "The private ip of the GitLab instance. Instance removed in HA"
  type        = string
}

variable "rds_address" {
  description = "The hostname of the RDS instance which does not have `port`"
  type        = string
}

variable "redis_address" {
  description = "The address of the endpoint for the primary node in the elasticache replication group, if the cluster mode is disabled."
  type        = string
}

variable "rds_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = "gitlabhq_production"
}

variable "rds_username" {
  description = "Username for the master DB user"
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

variable "gitlab_external_diffs_bucket_name" {
  description = "The external diffs bucket's name"
  type        = string
  default     = "gl-aws-external-diffs"
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

variable "gitlab_dependency_proxy_bucket_name" {
  description = "The dependency proxy bucket's name"
  type        = string
  default     = "gl-aws-dependency-proxy"
}

variable "gitlab_terraform_state_bucket_name" {
  description = "The terraform state bucket's name"
  type        = string
  default     = "gl-aws-terraform-state"
}

variable "gitaly_token" {
  description = "The token authenticate gRPC requests to Gitaly"
  type        = string
}

variable "secret_token" {
  description = "The token for authentication callbacks from GitLab Shell to the GitLab internal API"
  type        = string
}

variable "private_ips_gitaly" {
  description = "Assigned private ips to gitaly instances "
  type        = list(string)
}

variable "grafana_password" {
  description = "Password to access Grafana"
  type        = string
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