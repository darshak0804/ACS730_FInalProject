#Add variables
variable "default_tags" {
  default = {
    "Owner" = "ACS730-Group7-Final-Project"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

#Add variables
variable "prefix" {
  default     = "Group7"
  type        = string
  description = "Name prefix"
}

# Provision public subnets in custom VPC
variable "public_cidr_blocks" {
  default     = ["10.1.1.0/24" , "10.1.2.0/24" , "10.1.3.0/24" , "10.1.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}
# Provision private subnets in custom VPC
variable "private_cidr_blocks" {
  default     = ["10.1.5.0/24" , "10.1.6.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}
