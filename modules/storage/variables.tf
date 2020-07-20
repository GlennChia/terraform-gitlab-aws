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