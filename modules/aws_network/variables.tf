# VPC CIDR blocks
variable "vpc_cidr" {}

# Provision public subnets in custom VPC
variable "public_cidr_blocks" {}

# Provision private subnets in custom VPC
variable "private_cidr_blocks" {}

# Default tags
variable "default_tags" {}

# Prefix to identify resources
variable "prefix" {}
