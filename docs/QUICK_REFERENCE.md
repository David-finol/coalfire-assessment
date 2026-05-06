# Quick Reference Guide

## Fast Commands

### Setup (First Time)

```bash
# Linux/macOS
bash scripts/setup.sh

# Windows
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1

# Manual steps
cd terraform/state-backend && terraform apply
cd ../environments/dev && terraform init
```

### Daily Operations

```bash
# Plan changes
make plan

# Apply changes
make apply

# Destroy (use with care!)
make destroy

# View outputs
make outputs

# Validate code
make validate
```

### Accessing Infrastructure

```bash
# Get important IPs/DNS
terraform output management_instance_public_ip
terraform output alb_dns_name
terraform output asg_name

# SSH to management instance
ssh -i ~/.ssh/coalfire-key ec2-user@MGMT_IP

# SSH to app instance (from management)
ssh ec2-user@10.1.1.x

# Test web server
curl http://ALB_DNS_NAME
```

### Debugging

```bash
# Check what will change
terraform plan -out=tfplan

# See current state
terraform state list
terraform state show aws_instance.management

# Check AWS resources
aws ec2 describe-instances --filters Name=tag:Environment,Values=dev
aws autoscaling describe-auto-scaling-groups

# View logs
ssh -i ~/.ssh/coalfire-key ec2-user@MGMT_IP
tail -f /var/log/user-data.log
sudo systemctl status httpd
```

### Cleanup

```bash
# Remove everything
terraform destroy

# Clean cache
make clean

# Remove specific module
terraform destroy -target=module.compute
```

## Important Paths

| Item | Path |
|------|------|
| Dev Config | `terraform/environments/dev/` |
| Modules | `terraform/modules/` |
| Networking | `terraform/modules/networking/` |
| Security | `terraform/modules/security/` |
| Compute | `terraform/modules/compute/` |
| ALB | `terraform/modules/alb/` |
| CI/CD | `.github/workflows/terraform.yml` |
| Docs | `docs/` |
| Setup | `scripts/setup.sh` or `setup.ps1` |

## Key Variables to Know

```hcl
# Update your IP for SSH access
management_access_cidrs = ["YOUR_IP/32"]

# Adjust instance counts
asg_min_size = 2        # minimum instances
asg_max_size = 6        # maximum instances
asg_desired_capacity = 2  # target instances

# Change instance type
instance_type = "t2.micro"  # good for testing
# instance_type = "t3.small" # better for production

# Network CIDR blocks
vpc_cidr = "10.1.0.0/16"
```

## AWS Resource Naming

All resources follow pattern: `{environment}-{component}`

Examples:
- `dev-vpc` - VPC
- `dev-management-subnet` - Management subnet
- `dev-app-asg` - Auto Scaling Group
- `dev-alb` - Load Balancer
- `dev-management-instance` - Bastion host

## Common AWS CLI Commands

```bash
# List VPCs
aws ec2 describe-vpcs

# List Subnets
aws ec2 describe-subnets

# List EC2 Instances
aws ec2 describe-instances

# List Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups

# List Load Balancers
aws elbv2 describe-load-balancers

# List Security Groups
aws ec2 describe-security-groups

# Get specific resource details
aws ec2 describe-instances --instance-ids i-xxxxxxxx
```

## Default Values

| Component | Default |
|-----------|---------|
| Region | us-east-1 |
| VPC CIDR | 10.1.0.0/16 |
| Instance Type | t2.micro |
| ASG Min | 2 |
| ASG Max | 6 |
| ASG Target | 2 |
| ALB Port | 80 |
| SSH Port | 22 |

## Useful Links

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **AWS EC2**: https://console.aws.amazon.com/ec2
- **AWS VPC**: https://console.aws.amazon.com/vpc
- **AWS IAM**: https://console.aws.amazon.com/iam
- **Terraform Registry**: https://registry.terraform.io

## Time Estimates

| Operation | Time |
|-----------|------|
| State backend setup | 2-3 min |
| Initial terraform init | 1-2 min |
| First terraform apply | 8-12 min |
| Plan & Apply | 3-5 min |
| Destroy all | 5-10 min |
| SSH key generation | < 1 min |

## Emergency Procedures

### If something goes wrong:

1. **Don't panic** - resources can be recreated
2. **Check logs** - see troubleshooting guide
3. **Verify credentials** - `aws sts get-caller-identity`
4. **Check state** - `terraform state list`
5. **Run destroy if needed** - `terraform destroy`
6. **Clean and retry** - `make clean && terraform init`

### Quickly destroy and recreate:

```bash
# Remove everything
terraform destroy -auto-approve

# Clean cache
make clean

# Start fresh
terraform init
terraform apply
```

## Useful Terraform Commands

```bash
# Format all files
terraform fmt -recursive

# Validate syntax
terraform validate

# Show all resources
terraform state list

# Show specific resource
terraform state show aws_instance.management

# Remove resource from state (dangerous!)
terraform state rm aws_instance.management

# Import existing resource
terraform import aws_instance.management i-xxxxxxxx

# Target specific resource
terraform apply -target=module.compute

# Get detailed error logs
TF_LOG=DEBUG terraform plan

# Prevent destroy
terraform plan -prevent-destroy
```

---

For detailed information, refer to:
- [README.md](../README.md) - Main documentation
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Step-by-step deployment
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture diagrams
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solutions
