variable "vpc_cidr" {
  description = "VPC Cidr Range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to deploy the subnets in"
  type        = list(string)
}

variable "cidrsubnet_newbits" {
  description = "Second argument to cidrsubnet function"
  type        = number
  default     = 8
}