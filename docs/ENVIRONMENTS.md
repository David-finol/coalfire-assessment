# Environment-Specific Configuration

This document explains how to create and manage multiple Terraform environments.

## Creating Additional Environments

### Staging Environment

```bash
# Create staging environment directory
cp -r terraform/environments/dev terraform/environments/staging

# Update staging variables
cd terraform/environments/staging
nano terraform.tfvars

# Change these values:
environment = "staging"
asg_min_size = 3
asg_max_size = 10
asg_desired_capacity = 5
```

### Production Environment

```bash
# Create production environment directory
cp -r terraform/environments/dev terraform/environments/prod

# Update production variables
cd terraform/environments/prod
nano terraform.tfvars

# Change these values:
environment = "prod"
instance_type = "t3.small"  # Better for production
asg_min_size = 3
asg_max_size = 20
asg_desired_capacity = 6
```

## State Backend for Multiple Environments

Update `terraform/environments/prod/main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "coalfire-terraform-state-ACCOUNT_ID"
    key            = "coalfire-prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "coalfire-terraform-locks"
    encrypt        = true
  }
}
```

## Deployment Commands

```bash
# Dev
cd terraform/environments/dev
terraform plan
terraform apply

# Staging
cd terraform/environments/staging
terraform plan
terraform apply

# Production
cd terraform/environments/prod
terraform plan
terraform apply
```

## Environment Variables by Stage

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| ASG Min | 2 | 3 | 3 |
| ASG Max | 6 | 10 | 20 |
| Instance Type | t2.micro | t3.small | t3.medium |
| Backup | No | Yes | Yes |
| Monitoring | Basic | Enhanced | Full |

## Cross-Environment Considerations

- Use separate AWS accounts for better isolation
- Implement approval gates for production deployments
- Monitor costs per environment
- Maintain consistent tagging strategy
- Document environment-specific procedures
