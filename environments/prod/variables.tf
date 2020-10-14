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

variable "load_balancer_bucket" {
  description = "Bucket for the load balancer"
  type        = string
  default     = "gl-entry"
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

variable "rds_name_gitlab" {
  description = "The name of the database to create when the DB instance is created for GitLab instance"
  type        = string
  default     = "gitlabhq_production"
}

variable "rds_username_gitlab" {
  description = "Username for the master DB user for GitLab instance"
  type        = string
}

variable "rds_password_gitlab" {
  description = "Password for the master DB user for GitLab instance"
  type        = string
}

variable "deletion_protection" {
  description = "Database cannot be deleted if set to true"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = true
}

variable "gitlab_instance_type" {
  description = "The Gitlab instance type"
  type        = string
  default     = "c5.xlarge"
}

variable "gitlab_key_name" {
  description = "The GitLab key name of a key that has already been created"
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

variable "gitlab_aws_runner_cache" {
  description = "The Runner Cache bucket's name"
  type        = string
  default     = "gl-aws-runner-cache"
}

variable "visibility" {
  description = "Determines if the instance is private (behind a loadbalancer) or public (using its own dns)"
  type        = string
  default     = "private"
}

variable "private_ip_gitlab" {
  description = "The private ip of the GitLab instance. Instance removed in HA"
  type        = string
}
variable "rds_name_gitaly" {
  description = "The name of the database to create when the DB instance is created for Gitaly cluster"
  type        = string
  default     = "gitalyhq_production"
}

variable "rds_username_gitaly" {
  description = "Username for the master DB user for Gitaly cluster"
  type        = string
}

variable "rds_password_gitaly" {
  description = "Password for the master DB user for Gitaly cluster"
  type        = string
}

variable "gitaly_token" {
  description = "The token authenticate gRPC requests to Gitaly. For praefect, it is used in praefect_internal_token"
  type        = string
}

variable "secret_token" {
  description = "The token for authentication callbacks from GitLab Shell to the GitLab internal API"
  type        = string
}

variable "gitaly_config" {
  description = "The configuration for gitaly. Can be clustered or a single instance"
  type        = string
  default     = "clustered"
}

variable "private_ips_gitaly" {
  description = "Assigned private ips to gitaly instances"
  type        = list(string)
}

variable "gitaly_key_name" {
  description = "The Gitaly key name of a key that has already been created"
  type        = string
}

variable "grafana_password" {
  description = "Password to access Grafana"
  type        = string
}

variable "praefect_sql_password" {
  description = "Password for the praefect db user"
  type        = string
}

variable "praefect_external_token" {
  description = "Token needed by clients outside the cluster (like GitLab Shell) to communicate with the Praefect cluster"
  type        = string
}

variable "private_ips_praefect" {
  description = "Assigned private ips to praefect instances "
  type        = list(string)
}

variable "praefect_key_name" {
  description = "The key name of a key that has already been created that will be attached to the praefect instance"
  type        = string
}

variable "praefect_instance_type" {
  description = "Instance type for the praefect instance"
  type        = string
  default     = "c5.xlarge"
}

variable "launch_configuration_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix."
  type        = string
  default     = "gitlab-ha-launch-config"
}

variable "autoscaling_group_name" {
  description = "The name of the auto scaling group"
  type        = string
  default     = "gitlab-auto-scaling-group"
}