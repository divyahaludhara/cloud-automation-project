terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 6.0"
}
}
required_version = ">= 1.5.0"
}

provider "aws" {
region = var.aws_region
}

resource "aws_key_pair" "devops_key" {
key_name = "Network"
public_key = file("${path.module}/Network.pub")
}

resource "aws_security_group" "web_sg" {
name = "NetworkSG"
description = "Allows ports"

ingress {
description = "SSH Access"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
description = "HTTP Access"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
description = "Allow all outbound"
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "NetworkSG"
}
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "web" {
ami = var.ami_id
instance_type = var.instance_type
key_name = aws_key_pair.devops_key.key_name
vpc_security_group_ids = [aws_security_group.web_sg.id]

tags = {
Name = "AWS EC2"
}
}