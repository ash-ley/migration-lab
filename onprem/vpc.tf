locals {
  availability-zones = slice(data.aws_availability_zones.available.names, 0, var.number-of-azs)

  public_subnet_cidr  = [cidrsubnet(var.vpc-cidr, 8, 0), cidrsubnet(var.vpc-cidr, 8, 1)]
  private_subnet_cidr = [cidrsubnet(var.vpc-cidr, 8, 2), cidrsubnet(var.vpc-cidr, 8, 3)]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "onprem-vpc"
  cidr = var.vpc-cidr

  azs                   = local.availability-zones
  private_subnets       = [local.private_subnet_cidr[0], local.private_subnet_cidr[1]]
  private_subnet_suffix = "db"
  public_subnets        = [local.public_subnet_cidr[0], local.public_subnet_cidr[1]]
  public_subnet_suffix  = "app"

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "onprem"
  }
}
