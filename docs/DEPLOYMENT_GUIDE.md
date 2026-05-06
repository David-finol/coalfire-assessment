# Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [State Backend Configuration](#state-backend-configuration)
4. [Variable Configuration](#variable-configuration)
5. [Deployment Steps](#deployment-steps)
6. [Post-Deployment Validation](#post-deployment-validation)
7. [Accessing Your Infrastructure](#accessing-your-infrastructure)
8. [CI/CD Setup](#cicd-setup)

## Prerequisites

### Software Requirements

- **Terraform** >= 1.0 (https://www.terraform.io/downloads)
- **AWS CLI** >= 2.0 (https://aws.amazon.com/cli/)
- **Git** (for version control)
- **SSH Client** (for accessing EC2 instances)

### AWS Requirements

- AWS Account with administrative access
- Appropriate IAM permissions:
  - EC2 (create, modify, delete instances)
  - VPC (create, modify, delete VPCs, subnets, security groups)
  - ELB (create, modify, delete load balancers)
  - Auto Scaling (create, modify, delete ASGs)
  - IAM (create roles, policies, instance profiles)
  - S3 (create, modify buckets)
  - DynamoDB (create tables)

### Network Requirements

- Your public IP address (for management SSH access)
  - Find it at: https://www.myip.com or run `curl ifconfig.me`
- SSH key pair (generate or use existing)

## Initial Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/your-username/coalfire-assessment.git
cd coalfire-assessment
```

### Step 2: Install Requirements

**Linux/macOS:**

```bash
# Using Homebrew (macOS)
brew install terraform awscli

# Or download manually
# Terraform: https://www.terraform.io/downloads
# AWS CLI: https://aws.amazon.com/cli/
```

**Windows:**

```powershell
# Using Chocolatey
choco install terraform awscli

# Or download manually
# Terraform: https://www.terraform.io/downloads
# AWS CLI: https://aws.amazon.com/cli/
```

### Step 3: Configure AWS Credentials

```bash
aws configure

# You'll be prompted for:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: us-east-1
# Default output format: json
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## State Backend Configuration

The state backend stores your Terraform state in S3 with DynamoDB locking.

### Automated Setup (Recommended)

**Linux/macOS:**

```bash
bash scripts/setup.sh
```

**Windows PowerShell:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

This script:
1. Verifies AWS credentials
2. Creates S3 bucket for state
3. Creates DynamoDB table for locks
4. Initializes dev environment

### Manual Setup

If automated setup doesn't work:

```bash
# 1. Get your AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo $AWS_ACCOUNT_ID

# 2. Initialize state backend
cd terraform/state-backend

# 3. Update the bucket name in backend.tf if needed
# 4. Create the backend infrastructure
terraform init
terraform apply

# 5. Verify creation
aws s3 ls
aws dynamodb list-tables

# 6. Return to root
cd ../..
```

## Variable Configuration

### Edit terraform.tfvars

```bash
cd terraform/environments/dev

# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit the file
nano terraform.tfvars  # Linux/macOS
notepad terraform.tfvars  # Windows
```

### Critical Variable: Management Access CIDR

**IMPORTANT**: Update your IP in `terraform.tfvars`:

```hcl
# Find your public IP
# Linux/macOS:
curl ifconfig.me

# Windows PowerShell:
(Invoke-WebRequest -Uri "https://ifconfig.me").Content

# Then update terraform.tfvars:
management_access_cidrs = ["203.0.113.25/32"]  # Replace with YOUR IP
```

### All Available Variables

```hcl
# AWS Region
aws_region = "us-east-1"

# Environment identifier
environment = "dev"

# Network configuration
vpc_cidr                 = "10.1.0.0/16"
application_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
management_subnet_cidr   = "10.1.3.0/24"
backend_subnet_cidrs     = ["10.1.4.0/24", "10.1.5.0/24"]

# Compute configuration
instance_type            = "t2.micro"
asg_min_size             = 2
asg_max_size             = 6
asg_desired_capacity     = 2

# Security - MUST UPDATE
management_access_cidrs  = ["0.0.0.0/32"]  # Change to YOUR IP/CIDR
```

## Deployment Steps

### Step 1: Validate Configuration

```bash
cd terraform/environments/dev

# Format check
terraform fmt -check

# Validate syntax
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 2: Initialize Terraform

```bash
terraform init

# Output should show:
# - Backend initialized
# - Modules downloaded
# - Plugins installed
```

### Step 3: Create Execution Plan

```bash
terraform plan -out=tfplan

# Review the plan output:
# + aws_vpc.main
# + aws_subnet.application
# + aws_security_group.alb
# ... and more
```

### Step 4: Apply Configuration

```bash
# Review the plan output carefully, then:
terraform apply tfplan

# This will:
# 1. Create VPC and subnets
# 2. Create security groups
# 3. Create NAT gateways and routes
# 4. Create ALB and target group
# 5. Create launch template
# 6. Create Auto Scaling Group
# 7. Launch management EC2

# Expected time: 5-10 minutes
```

### Step 5: Verify Deployment

```bash
# Show all outputs
terraform output

# Show specific output
terraform output management_instance_public_ip
terraform output alb_dns_name
```

## Post-Deployment Validation

### Verify AWS Resources

```bash
# List VPCs
aws ec2 describe-vpcs --filters Name=tag:Environment,Values=dev

# List subnets
aws ec2 describe-subnets --filters Name=tag:Environment,Values=dev

# List security groups
aws ec2 describe-security-groups --filters Name=tag:Environment,Values=dev

# List Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dev-app-asg

# List load balancers
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `dev-alb`)]'
```

### Check EC2 Instances

```bash
# Get instance status
aws ec2 describe-instances --filters Name=tag:Environment,Values=dev

# Get specific instance details
aws ec2 describe-instances \
  --instance-ids i-0123456789abcdef0 \
  --query 'Reservations[0].Instances[0]'
```

### Test ALB Health

```bash
# Get target group health
aws elbv2 describe-target-health \
  --target-group-arn "arn:aws:elasticloadbalancing:..."

# Expected output should show instances as "healthy"
```

## Accessing Your Infrastructure

### Get Connection Information

```bash
cd terraform/environments/dev

# Get management instance IP
MGMT_IP=$(terraform output -raw management_instance_public_ip)
echo "Management IP: $MGMT_IP"

# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "ALB DNS: $ALB_DNS"

# Get ASG name
ASG_NAME=$(terraform output -raw asg_name)
echo "ASG Name: $ASG_NAME"
```

### SSH to Management Instance

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/coalfire-key

# SSH to management instance
ssh -i ~/.ssh/coalfire-key ec2-user@$MGMT_IP

# From the management instance, you can:
# 1. See all application instances
aws ec2 describe-instances --filters Name=tag:Environment,Values=dev

# 2. SSH to application instances (example)
ssh ec2-user@10.1.1.50  # Private IP of ASG instance
```

### Access Web Server via ALB

```bash
# Test ALB endpoint
curl http://$ALB_DNS

# You should see:
# <!DOCTYPE html>
# <html>
# <head>
#     <title>Coalfire Assessment</title>
# ...
```

### Monitor ASG

```bash
# Check instance health
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances'

# Check target group health
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(LoadBalancerName, 'dev-alb')].LoadBalancerArn" \
  --output text)

TG_ARN=$(aws elbv2 describe-target-groups \
  --load-balancer-arn $ALB_ARN \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

aws elbv2 describe-target-health --target-group-arn $TG_ARN
```

## CI/CD Setup

### Option 1: GitHub Actions (Recommended)

#### Prerequisites

- GitHub repository (public or private)
- AWS IAM role for GitHub Actions

#### Step 1: Create IAM Role

```bash
# Create a policy file: github-actions-policy.json
cat > github-actions-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "iam:*",
        "s3:*",
        "dynamodb:*",
        "vpc:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the role
aws iam create-role --role-name github-terraform-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
          "StringLike": {
            "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/*"
          }
        }
      }
    ]
  }'

# Attach policy to role
aws iam put-role-policy --role-name github-terraform-role \
  --policy-name terraform-policy \
  --policy-document file://github-actions-policy.json

# Get the role ARN
aws iam get-role --role-name github-terraform-role \
  --query 'Role.Arn' --output text
```

#### Step 2: Configure GitHub Secrets

1. Go to GitHub repository Settings → Secrets
2. Add secret: `AWS_ROLE_ARN`
   - Value: `arn:aws:iam::ACCOUNT_ID:role/github-terraform-role`

#### Step 3: Update Workflow

Edit `.github/workflows/terraform.yml`:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

#### Step 4: Push to GitHub

```bash
git add .
git commit -m "Add Terraform CI/CD configuration"
git push origin main
```

### Option 2: Manual Deployment

For testing or single deployments:

```bash
cd terraform/environments/dev
terraform plan
terraform apply
```

## Troubleshooting

### Common Issues

**Issue 1**: `terraform init` fails with "backend initialization required"

```bash
Solution:
terraform init -reconfigure
```

**Issue 2**: `terraform apply` fails with permission errors

```bash
Solution:
# Check AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam get-user
aws iam list-user-policies --user-name YOUR_USERNAME
```

**Issue 3**: Cannot SSH to management instance

```bash
Solution:
1. Check security group allows your IP:
   aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

2. Verify your IP is in management_access_cidrs

3. Check SSH key permissions:
   chmod 600 ~/.ssh/coalfire-key

4. Try with verbose output:
   ssh -vv -i ~/.ssh/coalfire-key ec2-user@PUBLIC_IP
```

**Issue 4**: ALB shows unhealthy targets

```bash
Solution:
1. Check instance user data logs:
   aws ssm start-session --target i-xxxxxxx
   sudo tail -f /var/log/user-data.log

2. Check security group rules:
   aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

3. Check target group health:
   aws elbv2 describe-target-health --target-group-arn arn:aws:...
```

## Cleanup

### Destroy All Infrastructure

```bash
cd terraform/environments/dev

# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Confirm when prompted
```

### Destroy Specific Resources

```bash
# Destroy only ASG
terraform destroy -target=module.compute.aws_autoscaling_group.app

# Destroy only ALB
terraform destroy -target=module.alb
```

## Cost Management

### Estimate Costs

```bash
# Use AWS pricing calculator
# https://calculator.aws/#/

# Or query AWS Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

### Cost Optimization Tips

1. Use t2.micro instances (eligible for free tier)
2. Set appropriate ASG min/max capacity
3. Use spot instances (edit launch template)
4. Delete unused resources promptly
5. Monitor CloudWatch metrics
6. Set up AWS Budgets for alerts

## Next Steps

1. [Review Architecture](ARCHITECTURE.md)
2. [Check Troubleshooting Guide](TROUBLESHOOTING.md)
3. [Implement Monitoring](MONITORING.md)
4. [Plan for Production](PRODUCTION_CHECKLIST.md)

---

For questions or issues, refer to the [main README](../README.md) or open a GitHub issue.
