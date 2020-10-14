variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the GitLab instance"
  type        = string
}

variable "image_id" {
  description = "The AMI ID of the GitLab image"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the GitLab instance"
  type        = string
  default     = "c5.xlarge"
}

variable "launch_configuration_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix."
  type        = string
  default     = "gitlab-ha-launch-config"
}

variable "security_groups" {
  description = "The list of security group ids associated with the GitLab instance"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The list of private subnet ids"
  type        = list(string)
}

variable "autoscaling_group_name" {
  description = "The name of the auto scaling group"
  type        = string
  default     = "gitlab-auto-scaling-group"
}

variable "target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing."
  type        = list(string)
}