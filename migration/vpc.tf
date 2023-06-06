locals {
  availability-zones      = slice(data.aws_availability_zones.available.names, 0, var.number-of-azs)

  app_netnum = [48, 49]
  db_netnum = [52, 53]
  staging_netnum = [16, 17]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "migration-vpc"
  cidr = var.vpc-cidr

  azs             = local.availability-zones
  private_subnets  = flatten([for i, v in local.availability-zones : [cidrsubnet(var.vpc-cidr, 9, element(local.app_netnum, i)), cidrsubnet(var.vpc-cidr, 9, element(local.db_netnum, i))]])
  public_subnets  = [for i, v in local.availability-zones : cidrsubnet(var.vpc-cidr, 8, element(local.staging_netnum, i))]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "migration"
  }
}