variable "number-of-azs" {
  type        = number
  description = "The number of availability zones for the VPC to deploy to."
}

variable "vpc-cidr" {
  type        = string
  description = "The VPC CIDR range."
}

variable "db_instance_type" {
  type        = string
  description = "Instance type for the db server"
}

variable "app_instance_type" {
  type        = string
  description = "Instance type for the app server"
}

variable "app_private_ip" {
  type        = string
  description = "Private IP for the app server"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
