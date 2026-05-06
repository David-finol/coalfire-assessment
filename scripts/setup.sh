#!/bin/bash
set -e

echo "================================"
echo "Coalfire Assessment - Quick Setup"
echo "================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "ERROR: terraform is not installed"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "ERROR: aws CLI is not installed"; exit 1; }

echo "✓ terraform installed"
echo "✓ aws CLI installed"
echo ""

# Get AWS account ID
echo "Getting AWS account information..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
echo "✓ AWS Account: $AWS_ACCOUNT_ID"
echo "✓ AWS Region: $AWS_REGION"
echo ""

# Create state backend
echo "Setting up Terraform state backend..."
cd terraform/state-backend

# Replace placeholder in backend.tf
sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" backend.tf 2>/dev/null || sed -i '' "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" backend.tf

terraform init
terraform apply -auto-approve

S3_BUCKET="coalfire-terraform-state-$AWS_ACCOUNT_ID"
echo "✓ State backend created:"
echo "  - S3 Bucket: $S3_BUCKET"
echo "  - DynamoDB Table: coalfire-terraform-locks"
echo ""

cd - > /dev/null

# Update dev environment backend configuration
echo "Updating dev environment backend configuration..."
sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" terraform/environments/dev/main.tf 2>/dev/null || sed -i '' "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" terraform/environments/dev/main.tf

# Initialize dev environment
echo "Initializing dev environment..."
cd terraform/environments/dev
terraform init
cd - > /dev/null

echo ""
echo "✓ Setup completed!"
echo ""
echo "Next steps:"
echo "1. Update management_access_cidrs in terraform/environments/dev/terraform.tfvars"
echo "2. Run: cd terraform/environments/dev && terraform plan"
echo "3. Review the plan and run: terraform apply"
echo ""
