variable "subnet_ids" {
  description = "The list of private subnet ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
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

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
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