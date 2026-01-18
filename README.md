# DevOps Bootcamp Final Project

## 🔗 Project URLs

| Service | URL | Status |
|---------|-----|--------|
| **Web Application** | http://web.zaidzahir.com | ✅ Live |
| **Monitoring Dashboard** | https://monitoring.zaidzahir.com | ✅ Live |
| **GitHub Repository** | https://github.com/z4id-27/devops-bootcamp-project | 📂 Public |

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Infrastructure Components](#infrastructure-components)
- [Deployment Guide](#deployment-guide)
- [Monitoring](#monitoring)
- [Access & Credentials](#access--credentials)
- [Technologies Used](#technologies-used)

---

## 🎯 Project Overview

This project demonstrates a complete DevOps infrastructure deployment on AWS, implementing:

- **Infrastructure as Code** using Terraform
- **Configuration Management** using Ansible
- **Containerization** with Docker
- **Monitoring & Observability** with Prometheus and Grafana
- **CI/CD** with GitHub Actions
- **Secure Access** via Cloudflare Tunnel

---

## 🏗️ Architecture

### Network Architecture

┌─────────────────────────────────────────────────────────────┐
│ VPC: 10.0.0.0/24 │
│ │
│ ┌──────────────────────┐ ┌────────────────────────┐ │
│ │ Public Subnet │ │ Private Subnet │ │
│ │ 10.0.0.0/25 │ │ 10.0.0.128/25 │ │
│ │ │ │ │ │
│ │ ┌───────────────┐ │ │ ┌─────────────────┐ │ │
│ │ │ Web Server │ │ │ │ Ansible │ │ │
│ │ │ 10.0.0.5 │ │ │ │ Controller │ │ │
│ │ │ (Public IP) │ │ │ │ 10.0.0.135 │ │ │
│ │ └───────────────┘ │ │ └─────────────────┘ │ │
│ │ │ │ │ │
│ │ │ │ ┌─────────────────┐ │ │
│ │ │ │ │ Monitoring │ │ │
│ │ │ │ │ Server │ │ │
│ └──────────────────────┘ │ │ 10.0.0.136 │ │ │
│ │ │ └─────────────────┘ │ │
│ │ │ │ │ │
│ ┌──────▼──────┐ │ ┌─────▼──────┐ │ │
│ │ Internet │ │ │ NAT │ │ │
│ │ Gateway │ │ │ Gateway │ │ │
│ └─────────────┘ │ └────────────┘ │ │
└───────────┬───────────────────┴───────────────────────┘ │
│
┌─────▼─────┐
│ Internet │
└───────────┘


### Component Overview

| Component | Subnet | Private IP | Public Access | Purpose |
|-----------|--------|------------|---------------|---------|
| **Web Server** | Public | 10.0.0.5 | ✅ Elastic IP | Host web application |
| **Ansible Controller** | Private | 10.0.0.135 | ❌ SSM only | Configuration management |
| **Monitoring Server** | Private | 10.0.0.136 | ❌ Cloudflare Tunnel | Prometheus & Grafana |

---

## 🔧 Infrastructure Components

### 1. Terraform Resources

#### Network Infrastructure
- **VPC**: `devops-vpc` (10.0.0.0/24)
- **Public Subnet**: 10.0.0.0/25
- **Private Subnet**: 10.0.0.128/25
- **Internet Gateway**: `devops-igw`
- **NAT Gateway**: `devops-ngw`
- **Route Tables**: Public and Private routes

#### Security Groups

**devops-public-sg** (Web Server)
- Port 80: Allow from 0.0.0.0/0 (HTTP)
- Port 9100: Allow from Monitoring Server (Node Exporter)
- Port 22: Allow from VPC subnet only

**devops-private-sg** (Ansible & Monitoring)
- Port 22: Allow from VPC subnet only

#### EC2 Instances

| Instance | Type | AMI | Storage |
|----------|------|-----|---------|
| Web Server | t3.micro | Ubuntu 24.04 | 8GB gp3 |
| Ansible Controller | t3.micro | Ubuntu 24.04 | 8GB gp3 |
| Monitoring Server | t3.micro | Ubuntu 24.04 | 8GB gp3 |

#### Container Registry
- **ECR Repository**: `devops-bootcampfinal-project-yourname`
- **Region**: ap-southeast-1

#### State Management
- **S3 Bucket**: `devops-bootcamp-terraform-yourname`
- **Backend**: Terraform state stored in S3

---

### 2. Ansible Playbooks

| Playbook | Purpose |
|----------|---------|
| `docker-install.yml` | Install Docker Engine on all servers |
| `deploy_web.yml` | Deploy web application container |
| `deploy_monitor.yml` | Deploy Prometheus & Grafana |

**Inventory Structure:**
```ini
[web]
10.0.0.5

[monitoring]
10.0.0.136

3. Containerized Services
Web Application
Image: Stored in AWS ECR

Port: 80

Source: https://github.com/Infratify/lab-final-project

Deployment: Docker container via Ansible

Monitoring Stack
Prometheus: Port 9090 (internal)

Grafana: Port 3000 (via Cloudflare Tunnel)

Node Exporter: Port 9100 (Web Server)

🚀 Deployment Guide
Prerequisites
AWS Account with appropriate IAM permissions

Terraform >= 1.0

Ansible >= 2.9

Domain registered with Cloudflare

GitHub account

Step 1: Clone Repository

git clone https://github.com/z4id-27/devops-bootcamp-project.git
cd devops-bootcamp-project

Step 2: Provision Infrastructure (Terraform)

cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply

Resources Created:

VPC with public/private subnets

3 EC2 instances

Security groups

ECR repository

Elastic IP

Step 3: Configure Servers (Ansible)
Access Ansible Controller via AWS SSM:


aws ssm start-session --target i-xxxxxxxxx

From Ansible Controller:

cd ~/devops-bootcamp-project/ansible

# Install Docker on all servers
ansible-playbook docker-install.yml

# Deploy web application
ansible-playbook deploy_web.yml

# Deploy monitoring stack
ansible-playbook deploy_monitor.yml


Step 4: Build & Push Docker Image

# Clone application source
git clone https://github.com/Infratify/lab-final-project.git
cd lab-final-project

# Build Docker image
docker build -t web-app .

# Tag for ECR
docker tag web-app:latest <ECR_URL>/web-app:latest

# Login to ECR
aws ecr get-login-password --region ap-southeast-1 | \
  docker login --username AWS --password-stdin <ECR_URL>

# Push to ECR
docker push <ECR_URL>/web-app:latest

Step 5: Configure Cloudflare
DNS Records

| Type | Name | Target                  | Proxy     |
| ---- | ---- | ----------------------- | --------- |
| A    | web  | [Web Server Elastic IP] | ✅ Proxied |

Cloudflare Tunnel
Create tunnel via Cloudflare Zero Trust

Configure public hostname: monitoring.zaidzahir.com → http://localhost:3000

Install cloudflared on Monitoring Server

Run tunnel with generated token

sudo cloudflared tunnel run --token <token>


Step 6: Verify Deployment
Web Application:

curl http://web.zaidzahir.com

Monitoring Dashboard:

Navigate to https://monitoring.zaidzahir.com

Login with Grafana credentials

📊 Monitoring
Prometheus Configuration
Scrape Targets:

Prometheus self-monitoring (localhost:9090)

Web Server Node Exporter (10.0.0.5:9100)

Metrics Collected:

CPU Usage

Memory Usage

Disk Usage

Network I/O

System Load

Grafana Dashboards
Dashboard: Infrastructure Monitoring

Visualizations:

CPU Usage (%) - Time series graph

Memory Usage (GB) - Gauge

Disk Usage (%) - Bar chart

Network Traffic - Area chart

Data Source: Prometheus (http://prometheus:9090)

Refresh Interval: 30 seconds


🔐 Access & Credentials
Grafana Access
URL: https://monitoring.zaidzahir.com

Username: admin

Password: test0092

AWS Systems Manager (SSM)
All EC2 instances accessible via SSM Session Manager:

# Web Server
aws ssm start-session --target i-web-server-id

# Ansible Controller
aws ssm start-session --target i-ansible-id

# Monitoring Server
aws ssm start-session --target i-monitoring-id

SSH Access (Internal)
From Ansible Controller:

# Web Server
ssh -i ~/.ssh/my-key.pem ubuntu@10.0.0.5

# Monitoring Server
ssh -i ~/.ssh/my-key.pem ubuntu@10.0.0.136

🛠️ Technologies Used

| Category                 | Tools                              |
| ------------------------ | ---------------------------------- |
| Infrastructure as Code   | Terraform                          |
| Configuration Management | Ansible                            |
| Cloud Provider           | AWS (VPC, EC2, ECR, S3, SSM)       |
| Containerization         | Docker, Docker Compose             |
| Monitoring               | Prometheus, Grafana, Node Exporter |
| DNS & CDN                | Cloudflare (DNS, Tunnel)           |
| CI/CD                    | GitHub Actions                     |
| Version Control          | Git, GitHub                        |
| Operating System         | Ubuntu 24.04 LTS                   |


📁 Repository Structure

devops-bootcamp-project/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions for documentation
├── ansible/
│   ├── ansible.cfg             # Ansible configuration
│   ├── inventory.ini           # Server inventory
│   ├── docker-install.yml      # Docker installation playbook
│   ├── deploy_web.yml          # Web app deployment playbook
│   ├── deploy_monitor.yml      # Monitoring deployment playbook
│   └── prometheus.yml          # Prometheus configuration
├── terraform/
│   ├── backend.tf              # Terraform backend (S3)
│   ├── providers.tf            # AWS provider configuration
│   ├── network.tf              # VPC, subnets, gateways
│   ├── security_groups.tf      # Security group rules
│   ├── ec2.tf                  # EC2 instance definitions
│   ├── ecr.tf                  # ECR repository
│   ├── ssm_iam.tf              # SSM IAM roles
│   ├── outputs.tf              # Terraform outputs
│   └── variables.tf            # Input variables
└── README.md                   # This documentation


👨‍💻 Author
Zaid Zahir

GitHub: @z4id-27

Project: DevOps Bootcamp 2025 Final Project

📄 License
This project is part of the DevOps Bootcamp final assessment.

© 2026 Infratify & Inframesia Technologies
