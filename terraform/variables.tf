variable "aws_region" {
description = "london region for deployment"
type = string
default = "eu-west-2"
}

variable "instance_type" {
description = "creates a EC2 instance type"
type = string
default = "t3.micro"
}

variable "ami_id" {
description = "Ubuntu AMI ID for eu-west-2"
type = string
default = "ami-018ff7ece22bf96db"
}