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
  cidr_block              = cidrsubnet(var.vpc_cidr, var.cidrsubnet_newbits, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "gitlab-public-${cidrsubnet(var.vpc_cidr, var.cidrsubnet_newbits, count.index)}"
  }
}

# Creates a private subnet in each AZ
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.cidrsubnet_newbits, length(var.availability_zones) + count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "gitlab-private-${cidrsubnet(var.vpc_cidr, var.cidrsubnet_newbits, length(var.availability_zones) + count.index)}",
    "kubernetes.io/cluster/gitlab" = "shared"
  }
}

resource "aws_eip" "this" {
  count = length(var.availability_zones)

  vpc = true

  tags = {
    Name = "gitlab-eip-ngw-${1 + count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.this]

  tags = {
    Name = "gitlab-nat-gateway-${1 + count.index}"
  }
}

resource "aws_vpc_endpoint" "this" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private.*.id

  tags = {
    Name = "gitlab-vpce"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "gitlab-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "gitlab-private-${1 + count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}