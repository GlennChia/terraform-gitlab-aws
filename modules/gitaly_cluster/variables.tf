variable "subnet_ids" {
  description = "The list of private subnet ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC Cidr Range used to allow Praefect NLB healthcheck to reach instances"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ingress_security_group_ids" {
  description = "The list security group id of the security group that is allowed ingress"
  type        = list(string)
}

variable "rds_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = "gitalyhq_production"
}

variable "allocated_storage" {
  description = "Allocated storage in gibibytes"
  type        = number
  default     = 100
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for. 0-35 range"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Database cannot be deleted if set to true. Override to `false` for dev"
  type        = bool
  default     = true
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "11.6"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.m4.large"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Choose between `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD)"
  type        = string
  default     = "gp2"
}

variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "rds_password" {
  description = "Password for the master DB user"
  type        = string
}

variable "publicly_accessible" {
  description = "Determines  the instance is publicly accessible"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. Override to `true` for dev"
  type        = bool
  default     = false
}

variable "praefect_sql_password" {
  description = "Password for the praefect db user"
  type        = string
}

variable "praefect_external_token" {
  description = "Token needed by clients outside the cluster (like GitLab Shell) to communicate with the Praefect cluster"
  type        = string
}

variable "praefect_internal_token" {
  description = "Token needed by to communicate with the Gitaly cluster"
  type        = string
}

variable "private_ips_gitaly" {
  description = "Assigned private ips to gitaly instances "
  type        = list(string)
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

variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the Gitaly and Praefect instance"
  type        = string
}

variable "ssh_ingress_security_group_id" {
  description = "The id of the security group allowed to ssh"
  type        = string
  default     = ""
}

variable "custom_ingress_security_group_id" {
  description = "The id of the security group allowed to communicate with Praefect"
  type        = string
  default     = ""
}

variable "prometheus_ingress_security_group_id" {
  description = "The id of the security group allowed to hit prometheus endpoint"
  type        = string
  default     = ""
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

variable "gitaly_key_name" {
  description = "The key name of a key that has already been created that will be attached to the gitaly instance"
  type        = string
}