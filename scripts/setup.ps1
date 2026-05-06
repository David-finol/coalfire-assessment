#!/bin/bash
# Setup script for Windows (PowerShell)
# Run: powershell -ExecutionPolicy Bypass -File scripts/setup.ps1

Write-Host "================================"
Write-Host "Coalfire Assessment - Quick Setup"
Write-Host "================================"
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..."

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: terraform is not installed"
    exit 1
}

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: aws CLI is not installed"
    exit 1
}

Write-Host "✓ terraform installed"
Write-Host "✓ aws CLI installed"
Write-Host ""

# Get AWS account ID
Write-Host "Getting AWS account information..."
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
$AWS_REGION = "us-east-1"
Write-Host "✓ AWS Account: $AWS_ACCOUNT_ID"
Write-Host "✓ AWS Region: $AWS_REGION"
Write-Host ""

# Create state backend
Write-Host "Setting up Terraform state backend..."
Push-Location "terraform\state-backend"

# Update backend.tf with account ID
(Get-Content backend.tf) -replace 'ACCOUNT_ID', $AWS_ACCOUNT_ID | Set-Content backend.tf

terraform init
terraform apply -auto-approve

$S3_BUCKET = "coalfire-terraform-state-$AWS_ACCOUNT_ID"
Write-Host "✓ State backend created:"
Write-Host "  - S3 Bucket: $S3_BUCKET"
Write-Host "  - DynamoDB Table: coalfire-terraform-locks"
Write-Host ""

Pop-Location

# Update dev environment backend configuration
Write-Host "Updating dev environment backend configuration..."
(Get-Content "terraform\environments\dev\main.tf") -replace 'ACCOUNT_ID', $AWS_ACCOUNT_ID | Set-Content "terraform\environments\dev\main.tf"

# Initialize dev environment
Write-Host "Initializing dev environment..."
Push-Location "terraform\environments\dev"
terraform init
Pop-Location

Write-Host ""
Write-Host "✓ Setup completed!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Update management_access_cidrs in terraform\environments\dev\terraform.tfvars"
Write-Host "2. Run: cd terraform\environments\dev; terraform plan"
Write-Host "3. Review the plan and run: terraform apply"
Write-Host ""
