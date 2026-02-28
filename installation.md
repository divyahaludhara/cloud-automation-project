## Prerequisites:

   - Login to AWS Console
   - Create an IAM user
         - Enter the username 
         - Don't click provide AWS managemnet console check-box 
         - Select AdministratorAccess in permission policies
         - Click "Create user".
   - After creating IAM user 
        - Click "AWS Console → IAM → Users → Security Credentials → Create Access Key" 
        - After creating the accesskey, download the csv file

## Step 1:
    - Verify AWS console installed
        - "aws --version"
    - Configure the AWS Console 
        - "aws configure"
            - Enter the IAM user Access key
            - Enter the IAM user secret key 
            - Enter the region : eu-west-1
            - Enter the Output format : json
    - verify the configuration
        - "aws sts get-caller-identity"
        
## Step 2:
    - Create Terraform project structure
        - terraform/
            │
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf    
    - In main.tf 
        - terraform block
             "terraform {
                required_providers {
                  aws = {
                    source  = "hashicorp/aws"
                    version = "~> 6.0"
                  }
                }
                required_version = ">= 1.5.0"
              }"

        - provider block(aws)
            provider "aws" {
                region = var.aws_region
            }         
        
        - ssh keypair resources
            resource "aws_key_pair" "devops_key" {
                key_name   = "aws-terraform-ssh"
                public_key = file("${path.module}/aws-terraform-ssh.pub")
            }
            - create a SSH Key pair inside the same folder of main.tf
                "ssh-keygen -t rsa -b 4096 -f aws-terraform-ssh"
        
        - security group block
            resource "aws_security_group" "web_sg" {
                  name        = "aws-terraform-sg"
                  description = "Allow SSH and HTTP"

                  ingress {
                    description = "SSH Access"
                    from_port   = 22
                    to_port     = 22
                    protocol    = "tcp"
                    cidr_blocks = ["0.0.0.0/0"]
                  }

                  ingress {
                    description = "HTTP Access"
                    from_port   = 80
                    to_port     = 80
                    protocol    = "tcp"
                    cidr_blocks = ["0.0.0.0/0"]
                 }

                  egress {
                    description = "Allow all outbound"
                    from_port   = 0
                    to_port     = 0
                    protocol    = "-1"
                   cidr_blocks = ["0.0.0.0/0"]
                  }

                  tags = {
                    Name = "aws-terraform-sg"
                  }
                }

        - EC2 instance block
            resource "aws_instance" "web" {
              ami                    = var.ami_id
              instance_type          = var.instance_type
              key_name               = aws_key_pair.devops_key.key_name
              vpc_security_group_ids = [aws_security_group.web_sg.id]

              tags = {
                Name = "DevOps-Web-Server"
              }
            }
    - In variables.tf
        variable "aws_region" {
            description = "AWS region for deployment"
            type        = string
            default     = "eu-west-1"
        }

        variable "instance_type" {
            description = "EC2 instance type"
            type        = string
            default     = "t3.micro"
        }

        variable "ami_id" {
            description = "Ubuntu AMI ID for eu-west-1"
            type        = string
            default     = "ami-03446a3af42c5e74e"
        }

    - In outputs.tf
        output "public_ip" {
            description = "Public IP of the EC2 instance"
            value       = aws_instance.web.public_ip
        }

        output "public_dns" {
            description = "Public DNS of the EC2 instance"
            value       = aws_instance.web.public_dns
        }

## Step 3:
    - Run the terraform configuration
        - Naviagate to the terraform folder
        - Run the following commands
            - "terraform init"
            - "terraform validate"
            - "terraform plan"
            - "terraform apply" 

## Step 4:
    - Connect to the EC2-instance
        - Navigate to the terraform folder
        - Run "ssh -i aws-terraform-ssh ubuntu@<PUBLIC_IP>"

## Step 5:

    - Go to wsl 
        - Navigate to the project home folder   
        - Type "wsl"
        - install ansible 
            - Run the following commands
                - "sudo apt update"
                - "sudo apt install ansible -y"
        - Verify ansible installed
            - "ansible --version"
        - Create ansible folder
            - "mkdir ansible"
            - Create inventory.ini and playbook.yml
                - "cd ansible"
                - "touch inventory.ini playbook.yml"
            - In inventory.ini
                - "[web]
                   <PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/aws-terraform-ssh"
            - In playbook.yml
                - "---
                    - name: Deploy Custom Web App
                    hosts: web
                    become: yes

                    tasks:

                        - name: Update apt packages
                        apt:
                            update_cache: yes

                        - name: Install Docker
                        apt:
                            name: docker.io
                            state: present

                        - name: Start Docker service
                        service:
                            name: docker
                            state: started
                            enabled: yes

                        - name: Add ubuntu user to docker group
                        user:
                            name: ubuntu
                            groups: docker
                            append: yes

                        - name: Create app directory on server
                        file:
                            path: /home/ubuntu/app
                            state: directory
                            owner: ubuntu
                            group: ubuntu

                        - name: Copy app files to server
                        copy:
                            src: ../app/
                            dest: /home/ubuntu/app/
                            owner: ubuntu
                            group: ubuntu

                        - name: Build Docker image
                        command: docker build -t custom-webapp /home/ubuntu/app

                        - name: Stop existing container if running
                        command: docker stop webapp
                        ignore_errors: yes

                        - name: Remove existing container if exists
                        command: docker rm webapp
                        ignore_errors: yes

                        - name: Run custom container
                        command: docker run -d --name webapp -p 80:80 --restart always custom-webapp" 
            -Run the ansible command
                - "ansible-playbook -i inventory.ini playbook.yml"
                - If error occurs during ansible connection:
                    - copy the ./terraform/aws-terraform-ssh file and paste it to ~/.ssh/aws-terraform-ssh
                    - Run "chmod 400 ~/.ssh/aws-terraform-ssh"


                
