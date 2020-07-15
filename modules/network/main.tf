/**
* # Network Module
*
* * Creates a VPC with all subnets having internet access. It has the following:
*   * VPC
*   * Public and Private subnets in each AZ within a specified region.
*   * Internet Gateway
*   * NatGateway in each public subnet
*   * Route tables
*/

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "gitlab-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "gitlab-gateway"
  }
}