variable "load_balancer_bucket" {
  description = "Bucket for the load balancer"
  type        = string
  default     = "gl-entry"
}

variable "acl" {
  description = "The canned ACL to apply. Options are `private`, `public-read`, `public-read-write` among others"
  type        = string
  default     = "private"
}

variable "force_destroy" {
  description = "Indicates that all objects should be deleted from the bucket so that it can be destroyed without error"
  type        = bool
  default     = true
}

variable "gitlab_buckets" {
  description = "List of gitlab buckets to create"
  type        = list(string)
  default     = ["gl-aws-artifacts", "gl-aws-external-diffs", "gl-aws-lfs-objects", "gl-aws-uploads", "gl-aws-packages", "gl-aws-dependency-proxy", "gl-aws-terraform-state", "gl-aws-runner-cache"]
}

variable "vpce_id" {
  description = "Id of the VPCE to associate with bucket policy"
  type        = string
}