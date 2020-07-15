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

variable "subnet_cidr_prefix" {
  description = "First 16 bits of cidr"
  type        = string
  default     = "10.0"
}

variable "subnet_cidr_suffix" {
  description = "Last 16 bits of cidr and length of the mask"
  type        = string
  default     = "0/24"
}