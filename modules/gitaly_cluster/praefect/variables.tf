variable "rds_address" {
  description = "The hostname of the RDS instance which does not have `port`"
  type        = string
}

variable "rds_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = "gitalyhq_production"
}

variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "rds_password" {
  description = "Password for the master DB user"
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

variable "praefect_internal_token" {
  description = "Token needed by to communicate with the Gitaly cluster"
  type        = string
}

variable "private_ips_gitaly" {
  description = "Assigned private ips to gitaly instances "
  type        = list(string)
}

variable "praefect_key_name" {
  description = "The key name of a key that has already been created that will be attached to the praefect instance"
  type        = string
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

variable "subnet_ids" {
  description = "Private subnet ids for clusters"
  type        = list(string)
}

variable "private_ips_praefect" {
  description = "Assigned private ips to praefect instances "
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type for the praefect instance"
  type        = string
  default     = "c5.xlarge"
}

variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the Praefect instance"
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