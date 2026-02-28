# Cloud Automation Project

## Overview
This project demonstrates automated deployment of a containerised web application on AWS using Terraform, Ansible, Docker, and GitHub Actions.

The infrastructure is provisioned using Terraform, configured using Ansible, and the application is containerised using Docker. A CI/CD pipeline automatically deploys updates to the EC2 instance whenever code is pushed to GitHub.

---

## Architecture

- Terraform provisions EC2 and Security Group
- Ansible configures the server and installs Docker
- Docker builds and runs the web application container
- GitHub Actions handles CI/CD deployment

---

## Project Structure
terraform/
ansible/
app/
.github/workflows/
README.md

---

## Prerequisites

- AWS Account
- Terraform installed
- Ansible installed (WSL used on Windows)
- Docker Desktop
- Git

---

## Infrastructure Deployment
terraform init
terraform plan
terraform apply

---

## Configuration Management

ansible-playbook -i inventory.ini playbook.yml

---

## CI/CD Pipeline

Whenever code is pushed to the main branch, GitHub Actions connects to the EC2 instance via SSH and executes the deployment script.

Pipeline file:
.github/workflows/CICDpipeline.yml

---

## Accessing the Application

Open in browser:

http://<EC2_PUBLIC_IP>

---

## Author

Divya Haludhar