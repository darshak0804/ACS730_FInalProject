# Define Public webservers security group config
resource "aws_security_group" "public_webservers_sg" {
  name        = "public_webservers_inbound_traffic_rules"
  description = "Rules for inbound SSH and HTTP traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id 

  ingress {
    description      = "Allow inbound HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "Allow inbound SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-public-webserver-sg"
    }
  )
}

# Define Private VMs security group config
resource "aws_security_group" "private_webservers_sg" {
  name        = "private_webservers_inbound_traffic_rules"
  description = "Rules for inbound SSH and HTTP traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id 

  ingress {
    description      = "SSH from public subnet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.public_webservers_sg.id]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-private-webserver-sg"
    }
  )
}