variable "number-of-azs" {
  type        = number
  description = "The number of availability zones for the VPC to deploy to."
}

variable "vpc-cidr" {
  type        = string
  description = "The VPC CIDR range."
}