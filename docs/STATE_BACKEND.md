# State Backend Setup Guide

This guide explains how to set up the Terraform state backend using S3 and DynamoDB.

## Overview

The state backend stores Terraform state remotely, enabling:
- **Team Collaboration** - Multiple users can work on the same infrastructure
- **State Locking** - Prevents concurrent modifications
- **Version History** - S3 versioning tracks all changes
- **Security** - Encrypted at rest and in transit

## Architecture

```
Your Machine
    │
    ├─ Push/Pull State
    │
    ▼
S3 Bucket (terraform.tfstate)
    ├─ Versioning enabled
    ├─ Encryption enabled
    └─ Public access blocked

    ┌─────────────────┐
    │  DynamoDB Table │
    │  (Lock Table)   │
    │  - LockID: key  │
    │  - Expires: 30s │
    └─────────────────┘
```

## Automatic Setup

The easiest way is to use the provided scripts:

**Linux/macOS:**
```bash
bash scripts/setup.sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

These scripts will:
1. Verify AWS credentials
2. Create S3 bucket
3. Create DynamoDB table
4. Initialize Terraform
5. Update backend configuration

## Manual Setup

If you prefer to set up manually:

### Step 1: Create S3 Bucket

```bash
# Set your account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create bucket
aws s3 mb s3://coalfire-terraform-state-$AWS_ACCOUNT_ID --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket coalfire-terraform-state-$AWS_ACCOUNT_ID \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket coalfire-terraform-state-$AWS_ACCOUNT_ID \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket coalfire-terraform-state-$AWS_ACCOUNT_ID \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Step 2: Create DynamoDB Table

```bash
# Create table
aws dynamodb create-table \
  --table-name coalfire-terraform-locks \
  --attribute-definitions \
    AttributeName=LockID,AttributeType=S \
  --key-schema \
    AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Verify creation
aws dynamodb describe-table \
  --table-name coalfire-terraform-locks
```

### Step 3: Initialize Terraform

```bash
cd terraform/environments/dev

# Initialize with backend
terraform init

# Verify backend is configured
terraform state list
```

## Backend Configuration

Update `terraform/environments/dev/main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "coalfire-terraform-state-ACCOUNT_ID"
    key            = "coalfire/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "coalfire-terraform-locks"
    encrypt        = true
  }
}
```

Replace `ACCOUNT_ID` with your actual AWS account ID.

## Verifying Setup

```bash
# Check S3 bucket
aws s3 ls s3://coalfire-terraform-state-$AWS_ACCOUNT_ID

# Check DynamoDB table
aws dynamodb list-tables

# Verify state is remote
cd terraform/environments/dev
terraform state list

# Should show remote state files from S3
```

## State File Location

After setup, state is stored at:
```
s3://coalfire-terraform-state-ACCOUNT_ID/coalfire/terraform.tfstate
```

## State Locks

### How Locking Works

```
User runs: terraform apply
  │
  ├─ DynamoDB: Create lock entry
  │    LockID: "coalfire/terraform.tfstate"
  │    Expires: NOW + 30s (auto-unlock if timeout)
  │
  ├─ Apply infrastructure changes
  │
  ├─ DynamoDB: Delete lock entry
  │
  └─ Done
```

### Monitoring Locks

```bash
# View current locks
aws dynamodb get-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}'

# If lock exists, shows:
# {
#   "Item": {
#     "LockID": {"S": "coalfire/terraform.tfstate"},
#     ...
#   }
# }
```

### Force Unlock

Use only if absolutely necessary:

```bash
# Get lock ID
LOCK_ID=$(aws dynamodb get-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}' \
  --query 'Item.ID.S' --output text)

# Force unlock
terraform force-unlock $LOCK_ID

# Or delete lock directly (dangerous!)
aws dynamodb delete-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}'
```

## Migration from Local State

If you have local state file:

```bash
# Backup local state
cp terraform.tfstate terraform.tfstate.backup

# Initialize with backend
terraform init

# Terraform will ask to migrate state
# Answer 'yes' to migrate local state to remote
```

## Backup and Restore

### Backup

```bash
# S3 has versioning enabled automatically
# To download current state:
aws s3 cp s3://coalfire-terraform-state-$AWS_ACCOUNT_ID/coalfire/terraform.tfstate ./state-backup.tfstate

# List all versions
aws s3api list-object-versions \
  --bucket coalfire-terraform-state-$AWS_ACCOUNT_ID \
  --prefix coalfire/terraform.tfstate
```

### Restore

```bash
# Download previous version
VERSION_ID="version-id-here"
aws s3api get-object \
  --bucket coalfire-terraform-state-$AWS_ACCOUNT_ID \
  --key coalfire/terraform.tfstate \
  --version-id $VERSION_ID \
  ./terraform.tfstate.old

# Review and use if needed
```

## Multi-Environment State

For multiple environments (dev, staging, prod), use different keys:

```hcl
# terraform/environments/dev/main.tf
backend "s3" {
  key = "coalfire-dev/terraform.tfstate"
  ...
}

# terraform/environments/staging/main.tf
backend "s3" {
  key = "coalfire-staging/terraform.tfstate"
  ...
}

# terraform/environments/prod/main.tf
backend "s3" {
  key = "coalfire-prod/terraform.tfstate"
  ...
}
```

Each environment has its own state file and can be locked independently.

## Troubleshooting

### "Backend initialization required"

```bash
# Solution: Reconfigure backend
terraform init -reconfigure
```

### "Error reading S3 Bucket"

```bash
# Check bucket exists
aws s3 ls | grep terraform-state

# Check credentials have S3 access
aws s3 ls
```

### "Error acquiring the state lock"

```bash
# Wait a moment and retry
sleep 30
terraform plan

# Or check lock status
aws dynamodb get-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}'
```

## Cost Estimation

| Component | Cost | Notes |
|-----------|------|-------|
| S3 Storage | <$1/month | State file is small (~100KB) |
| S3 Requests | <$1/month | Minimal API calls |
| DynamoDB | <$1/month | On-demand billing, minimal usage |

**Total**: <$2/month for state backend

## Security Best Practices

- [x] S3 encryption enabled
- [x] S3 versioning enabled
- [x] Public access blocked
- [x] DynamoDB on-demand billing
- [x] State locking prevents conflicts
- [ ] Consider: MFA Delete for S3 (optional)
- [ ] Consider: KMS encryption (optional)
- [ ] Consider: S3 access logging (optional)

## Next Steps

1. Verify backend is set up: `terraform state list`
2. Deploy infrastructure: `terraform apply`
3. Monitor state changes: `aws s3 ls`
4. Set up CI/CD: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

---

For questions, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
