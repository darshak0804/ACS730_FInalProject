variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC to host static website"
}

variable "public_subnet_cidrs" {
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

variable "private_subnet_cidrs" {
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

variable "default_tags" {
  default = {
    "Owner" = "Group 7",
    "App"   = "WebApp"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Name prefix to identify resources
variable "prefix" {
  default     = "Group 7"
  type        = string
  description = "Name prefix"
  }