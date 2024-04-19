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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "acs730-final-project-group7-${var.env}"
    key    = "${var.env}/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"

}

# Provisioning the private webserver VMs
resource "aws_instance" "private_webservers" {
  count                  = length(data.terraform_remote_state.network.outputs.private_subnets_id)
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instance_type, var.env)
  key_name               = aws_key_pair.ssh_keypair.key_name
  security_groups        = [aws_security_group.private_webservers_sg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnets_id[count.index]
  associate_public_ip_address = false
    
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }  

  tags = merge(local.default_tags, 
    {
    "Name" = "${var.prefix}-${var.env}-private-webserver-${count.index + 1}"
    }
  )
}

# Provisioning the public webserver VMs
resource "aws_instance" "public_webservers" {
    count                  = length(data.terraform_remote_state.network.outputs.public_subnets_id)
    ami                    = data.aws_ami.latest_amazon_linux.id
    instance_type          = lookup(var.instance_type, var.env)
    key_name               = aws_key_pair.ssh_keypair.key_name
    security_groups        = [aws_security_group.public_webservers_sg.id]
    subnet_id              = data.terraform_remote_state.network.outputs.public_subnets_id[count.index]
    associate_public_ip_address = true
    user_data = count.index < 2 ? templatefile("install_httpd.sh.tpl",
      {
        env    = upper(var.env),
        prefix = upper(var.prefix)
      }
    ) : null

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }    

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-${var.env}-public-webserver-${count.index + 1}"
    }
  )
}

# Create Elastic IP addresses for the webserver VMs
resource "aws_eip" "static_eip" {
  count   = length(data.terraform_remote_state.network.outputs.public_subnets_id)
  instance = aws_instance.public_webservers[count.index].id
  tags = merge(local.default_tags,
    {
      "Name" = "${var.env}-eip"
    }
  )
}

# Adding SSH key to be used by EC2 instance
resource "aws_key_pair" "ssh_keypair" {
  key_name   = "${var.env}-keypair"
  public_key = file("~/.ssh/${var.env}-key.pub")
}

# Attach EBS volume
resource "aws_volume_attachment" "ebs_att" {
  count       = var.env == "prod" ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web_ebs[count.index].id
  instance_id = aws_instance.public_webservers[count.index].id
}

# Create another EBS volume for prod environment
resource "aws_ebs_volume" "web_ebs" {
  count             = var.env == "prod" ? 1 : 0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  size              = 40
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-additional-EBS-volume"
    }
  )
}