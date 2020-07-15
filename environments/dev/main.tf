/**
* # Dev environment
*
* Link for manual installation: [Installing GitLab on Amazon Web Services (AWS)](https://docs.gitlab.com/ee/install/aws/)
*/

terraform {
  required_version = ">= 0.12.28"
  required_providers {
    aws = ">= 2.70.0"
  }
}

data "aws_availability_zones" "available" {}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "network" {
  source             = "../../modules/network"
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  cidrsubnet_newbits = var.cidrsubnet_newbits
}