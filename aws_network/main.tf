terraform {
  required_providers {
    aws = {
    source = "hashicorp/aws"
    version = ">= 3.27"
    } 
  }

  required_version = ">=0.14"
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  default_tags = merge(var.default_tags, {})
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags, {
      Name = "VPC-${var.prefix}"
    }
  )
}

# Making public subnets in VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}

# Making private subnets in VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-IGW"
    }
  )
}

# Route table of public subnets accessing Internet Gateway (IGW)
resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-subnets-route-table"
  }
}

# Associate public subnets with the custom route table
resource "aws_route_table_association" "public_subnets_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnets_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-NAT-Gateway"
    }
  )
}

# Route table for private subnets
resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.prefix}-private-subnets-route-table"
  }
}

# Associate private subnets with the custom route table
resource "aws_route_table_association" "private_subnets_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_subnets_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
