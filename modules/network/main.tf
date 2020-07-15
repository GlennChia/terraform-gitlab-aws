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

# Creates a public subnet in each AZ
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = join(".", [var.subnet_cidr_prefix, count.index, var.subnet_cidr_suffix])
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "gitlab-public-${var.subnet_cidr_prefix}.${count.index}.${var.subnet_cidr_suffix}"
  }
}

# Creates a private subnet in each AZ
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = join(".", [var.subnet_cidr_prefix, "${length(var.availability_zones) + count.index}", var.subnet_cidr_suffix])
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "gitlab-private-${var.subnet_cidr_prefix}.${length(var.availability_zones) + count.index}.${var.subnet_cidr_suffix}"
  }
}