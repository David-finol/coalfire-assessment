# Coalfire SRE Assessment - AWS Infrastructure

A production-ready Infrastructure-as-Code solution for deploying a scalable, secure AWS environment with Terraform.

## What's Included

- **VPC** with 3 subnets across 2 availability zones (10.1.0.0/16)
- **Application Load Balancer** routing to EC2 instances
- **Auto Scaling Group** (2-6 t2.micro instances) running Apache
- **Management EC2** instance for SSH access
- **Security Groups** with proper network segmentation
- **Remote State** storage with S3 and DynamoDB locking
- **GitHub Actions** CI/CD pipeline for automated deployment

## Prerequisites

\\ash
terraform -v          # Terraform 1.15.2+
aws --version         # AWS CLI v2
git --version         # Git
\
Configure AWS credentials:
\\ash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1)
\
## Quick Start

### 1. Clone Repository
\\ash
git clone https://github.com/David-finol/coalfire-assessment.git
cd coalfire-assessment
\
### 2. Create State Backend (First Time Only)
\\ash
cd terraform/state-backend
terraform init
terraform apply
# Creates S3 bucket and DynamoDB table for state
\
### 3. Deploy Infrastructure
\\ash
cd ../environments/dev

# Copy and update variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: Update management_access_cidrs with YOUR IP
# Example: management_access_cidrs = [" 203.0.113.0/32]
