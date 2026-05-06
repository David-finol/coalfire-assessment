# Troubleshooting Guide

## Table of Contents

1. [Terraform Errors](#terraform-errors)
2. [AWS Errors](#aws-errors)
3. [SSH and Access Issues](#ssh-and-access-issues)
4. [ALB and Application Issues](#alb-and-application-issues)
5. [State Management Issues](#state-management-issues)
6. [CI/CD Pipeline Issues](#cicd-pipeline-issues)

## Terraform Errors

### Error: "terraform init" fails with "backend initialization required"

**Symptoms**:
```
Error: Backend initialization required
```

**Causes**:
- First time running init with backend
- Backend configuration changed
- Incomplete initial setup

**Solutions**:
```bash
# Option 1: Reconfigure backend
terraform init -reconfigure

# Option 2: Reinitialize from scratch
rm -rf .terraform
rm -rf .terraform.lock.hcl
terraform init
```

### Error: "Error reading S3 Bucket for state"

**Symptoms**:
```
Error reading S3 Bucket for state: error reading S3 Bucket
```

**Causes**:
- S3 bucket doesn't exist
- AWS credentials don't have S3 access
- Bucket name is incorrect

**Solutions**:
```bash
# Verify bucket exists
aws s3 ls | grep terraform-state

# Create bucket if missing
aws s3 mb s3://coalfire-terraform-state-ACCOUNT_ID

# Verify credentials
aws sts get-caller-identity
```

### Error: "Error acquiring the state lock"

**Symptoms**:
```
Error acquiring the state lock: DynamoDB
```

**Causes**:
- DynamoDB table doesn't exist
- Another operation is holding the lock
- Network connectivity issue

**Solutions**:
```bash
# Check if DynamoDB table exists
aws dynamodb list-tables

# Check lock status
aws dynamodb get-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}'

# Force unlock (if lock is stuck - use with caution!)
terraform force-unlock LOCK_ID

# Wait and retry
sleep 30
terraform plan
```

### Error: "Invalid resource name"

**Symptoms**:
```
Error: Invalid resource name
  on modules/networking/main.tf line XX: resource "aws_xxx" "name"
  resource must have a valid, non-empty name
```

**Causes**:
- Typo in resource name
- Empty resource name
- Invalid characters in name

**Solutions**:
```bash
# Check syntax
terraform fmt -recursive
terraform validate

# Review the specific line
cat modules/networking/main.tf | sed -n 'XXp'
```

### Error: "Variable value could not be parsed"

**Symptoms**:
```
Error: Variable value could not be parsed
```

**Causes**:
- Invalid tfvars format
- Missing quotes
- Syntax error in variables

**Solutions**:
```bash
# Validate tfvars file
terraform validate

# Check tfvars syntax
cat terraform.tfvars

# Example correct format:
# management_access_cidrs = ["203.0.113.0/32"]
# NOT: management_access_cidrs = [203.0.113.0/32]
```

## AWS Errors

### Error: "AuthFailure" or "UnauthorizedOperation"

**Symptoms**:
```
Error: AuthFailure / UnauthorizedOperation
```

**Causes**:
- AWS credentials not configured
- Credentials expired
- Insufficient IAM permissions

**Solutions**:
```bash
# Verify credentials are set
aws configure list

# Check current identity
aws sts get-caller-identity

# Reconfigure credentials
aws configure

# Export credentials (alternative)
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Error: "An error occurred (InsufficientInstanceCapacity)"

**Symptoms**:
```
Error: An error occurred (InsufficientInstanceCapacity)
```

**Causes**:
- Availability zone full
- Instance type not available
- Resource limit reached

**Solutions**:
```bash
# Change instance type
# Edit terraform.tfvars
instance_type = "t2.small"

# Try different availability zone
# Edit terraform/environments/dev/terraform.tfvars
# Or let module auto-select

# Try different region
aws_region = "us-west-2"

# Check available capacity
aws ec2 describe-reserved-instances-offerings \
  --filters Name=instance-type,Values=t2.micro
```

### Error: "VpcLimitExceeded"

**Symptoms**:
```
Error: VpcLimitExceeded
```

**Causes**:
- Account has too many VPCs
- VPC limit reached (default 5)

**Solutions**:
```bash
# Check VPC count
aws ec2 describe-vpcs --query 'Vpcs | length'

# Request limit increase
# Via AWS Console:
# 1. Go to Service Quotas
# 2. Search for VPC
# 3. Request quota increase

# Or delete unused VPCs
aws ec2 delete-vpc --vpc-id vpc-xxxxxxxx
```

## SSH and Access Issues

### Error: "Connection timed out" when SSHing to management instance

**Symptoms**:
```
ssh: connect to host 203.0.113.1 port 22: Connection timed out
```

**Causes**:
- Security group doesn't allow SSH
- IP not in management_access_cidrs
- Instance not fully initialized
- Network connectivity issue

**Solutions**:
```bash
# 1. Verify security group allows your IP
MGMT_SG=$(terraform output -raw management_sg_id)
aws ec2 describe-security-groups --group-ids $MGMT_SG

# 2. Check your current IP
curl ifconfig.me

# 3. Update terraform.tfvars if needed
# management_access_cidrs = ["YOUR_IP/32"]

# 4. Apply changes
terraform apply

# 5. Wait for security group to update
sleep 30

# 6. Try SSH again with verbose output
ssh -vv -i ~/.ssh/coalfire-key ec2-user@PUBLIC_IP

# 7. If still failing, check instance is running
aws ec2 describe-instances --instance-ids i-xxxxxxxx \
  --query 'Reservations[0].Instances[0].State'
```

### Error: "Permission denied (publickey)"

**Symptoms**:
```
Permission denied (publickey)
```

**Causes**:
- SSH key doesn't exist
- Wrong SSH key
- SSH key permissions too open
- User doesn't exist on instance

**Solutions**:
```bash
# 1. Verify SSH key exists and has correct permissions
ls -la ~/.ssh/coalfire-key
chmod 600 ~/.ssh/coalfire-key

# 2. Verify key is correct
# Should have been created during terraform apply
# or provided as EC2 key pair

# 3. Use correct username for Amazon Linux 2
ssh -i ~/.ssh/coalfire-key ec2-user@PUBLIC_IP
# NOT: ubuntu, root, admin, etc.

# 4. If you have multiple keys, specify which one
ssh -i ~/.ssh/coalfire-key -v ec2-user@PUBLIC_IP

# 5. If key is corrupted, generate new one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/coalfire-key
# Then update EC2 key pair in AWS
```

### Error: "Host key verification failed"

**Symptoms**:
```
Host key verification failed
```

**Causes**:
- First time connecting to host
- SSH known_hosts file outdated

**Solutions**:
```bash
# 1. Accept host key
# Press 'yes' when prompted

# 2. Or disable key checking (not recommended for security)
ssh -o StrictHostKeyChecking=no -i ~/.ssh/coalfire-key ec2-user@PUBLIC_IP

# 3. Remove old host key
ssh-keygen -R PUBLIC_IP

# 4. Try again
ssh -i ~/.ssh/coalfire-key ec2-user@PUBLIC_IP
```

## ALB and Application Issues

### Error: "ALB shows unhealthy targets"

**Symptoms**:
```
Target health check status: Unhealthy (Status check failed)
```

**Causes**:
- Application not running
- Security group blocks health check traffic
- Health check path doesn't exist
- Instance still initializing

**Solutions**:
```bash
# 1. Check instance status
MGMT_IP=$(terraform output -raw management_instance_public_ip)
ssh -i ~/.ssh/coalfire-key ec2-user@$MGMT_IP

# 2. From management instance, check application instance
# Get ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dev-app-asg \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text

# 3. SSH to instance and check Apache
ssh ec2-user@10.1.1.50  # Private IP of ASG instance
sudo systemctl status httpd
sudo tail -f /var/log/httpd/access_log

# 4. Check if port 80 is listening
netstat -tuln | grep 80

# 5. Verify security group allows HTTP from ALB
ALB_SG=$(terraform output -raw alb_sg_id)
ASG_SG=$(terraform output -raw app_asg_sg_id)
aws ec2 describe-security-groups --group-ids $ASG_SG

# 6. Wait for instances to initialize
# First deployment can take 5-10 minutes
sleep 300
aws elbv2 describe-target-health \
  --target-group-arn "arn:aws:elasticloadbalancing:..."

# 7. Check user data logs
sudo tail -f /var/log/user-data.log
```

### Error: "Cannot access ALB endpoint"

**Symptoms**:
```
curl: (7) Failed to connect to coalfire-alb-xxx.amazonaws.com port 80
curl: (28) Connection timeout
```

**Causes**:
- ALB not created yet
- No healthy targets
- Security group blocks traffic
- DNS not resolving

**Solutions**:
```bash
# 1. Verify ALB exists
ALB_DNS=$(terraform output -raw alb_dns_name)
echo $ALB_DNS

# 2. Check if ALB is active
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?LoadBalancerName==`dev-alb`]'

# 3. Check target health
aws elbv2 describe-target-health \
  --target-group-arn "arn:aws:elasticloadbalancing:..."

# 4. Verify DNS resolves
nslookup $ALB_DNS
dig $ALB_DNS

# 5. Check ALB security group
ALB_SG=$(terraform output -raw alb_sg_id)
aws ec2 describe-security-groups --group-ids $ALB_SG

# 6. Try direct connection (if you have private access)
curl -I http://10.1.1.50  # Direct to instance
curl -I http://$ALB_DNS   # Through ALB
```

## State Management Issues

### Error: "State lock timeout"

**Symptoms**:
```
Error: Failed to acquire state lock
Acquired state lock timeout
```

**Causes**:
- Another terraform operation is running
- Previous operation left lock hanging
- DynamoDB latency

**Solutions**:
```bash
# 1. Wait for other operations to complete
sleep 60
terraform plan

# 2. Check lock status
aws dynamodb get-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}' \
  --region us-east-1

# 3. Force unlock if stuck (use caution!)
# Get the lock ID from:
terraform force-unlock LOCK_ID

# 4. Or delete stuck lock manually (DANGEROUS!)
aws dynamodb delete-item \
  --table-name coalfire-terraform-locks \
  --key '{"LockID":{"S":"coalfire/terraform.tfstate"}}'
```

### Error: "State mismatch after apply"

**Symptoms**:
```
Error: No matching resource found in the state
```

**Causes**:
- State file corrupted
- Manual AWS changes
- Network connectivity issue during apply

**Solutions**:
```bash
# 1. Refresh state
terraform refresh

# 2. View current state
terraform state list

# 3. Show specific resource state
terraform state show aws_instance.management

# 4. If corrupted, re-import resource
terraform import aws_instance.management i-xxxxxxxx

# 5. Or destroy and recreate
terraform destroy -target=aws_instance.management
terraform apply -target=aws_instance.management
```

## CI/CD Pipeline Issues

### Error: "GitHub Actions workflow fails on apply"

**Symptoms**:
```
Error: NotAuthenticatedError
```

**Causes**:
- AWS credentials not configured
- Role ARN incorrect
- OIDC provider not configured

**Solutions**:
```bash
# 1. Verify AWS_ROLE_ARN secret is set in GitHub
# Go to: Settings → Secrets → AWS_ROLE_ARN

# 2. Check role exists and is correct
aws iam get-role --role-name github-terraform-role

# 3. Verify OIDC provider is configured
aws iam list-open-id-connect-providers

# 4. If OIDC provider doesn't exist, create it:
# Use AWS CLI or create manually in Console

# 5. Update workflow to use correct role:
# .github/workflows/terraform.yml
# with:
#   role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

# 6. Re-run workflow manually
# GitHub: Actions → Workflow → Re-run jobs
```

### Error: "Workflow plan comment fails on PR"

**Symptoms**:
```
Error: No token available
```

**Causes**:
- GitHub token not available in workflow
- Workflow permissions not set

**Solutions**:
```yaml
# In .github/workflows/terraform.yml, ensure:
permissions:
  contents: read
  pull-requests: write

# And use:
uses: actions/github-script@v7
with:
  github-token: ${{ secrets.GITHUB_TOKEN }}
```

## General Troubleshooting Steps

### When in doubt, follow this checklist:

1. **Verify AWS Credentials**
   ```bash
   aws sts get-caller-identity
   aws ec2 describe-vpcs
   ```

2. **Check Terraform Version**
   ```bash
   terraform version  # Should be >= 1.0
   ```

3. **Validate Configuration**
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

4. **Check Logs**
   ```bash
   # Terraform debug logs
   export TF_LOG=DEBUG
   terraform plan

   # AWS logs
   aws logs tail /aws/ec2/coalfire-app-dev --follow
   ```

5. **Enable Verbose Output**
   ```bash
   # Terraform verbose
   terraform plan -lock-timeout=5m -var-file=terraform.tfvars

   # SSH verbose
   ssh -vv -i ~/.ssh/coalfire-key ec2-user@IP
   ```

6. **Test Connectivity**
   ```bash
   # Check AWS connectivity
   aws s3 ls

   # Check EC2 connectivity
   ping PUBLIC_IP
   curl http://ALB_DNS
   ```

7. **Review Recent Changes**
   ```bash
   git log --oneline -10
   git diff HEAD
   terraform state list
   ```

8. **Consult Logs**
   ```bash
   # Application logs
   sudo tail -f /var/log/httpd/error_log
   sudo tail -f /var/log/httpd/access_log

   # System logs
   sudo tail -f /var/log/messages
   sudo tail -f /var/log/cloud-init-output.log
   ```

## Getting Help

1. **Check Official Documentation**
   - [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
   - [AWS Documentation](https://docs.aws.amazon.com/)
   - [Terraform Docs](https://www.terraform.io/docs)

2. **Search for Similar Issues**
   - GitHub Issues in this repository
   - Terraform GitHub Issues
   - AWS Forums

3. **Enable Debug Logging**
   ```bash
   export TF_LOG=TRACE
   export TF_LOG_PATH=terraform-debug.log
   terraform plan
   tail -f terraform-debug.log
   ```

4. **Contact Support**
   - AWS Support (for AWS-specific issues)
   - Terraform Community (for IaC issues)
   - Repository maintainers (for this project)

---

If your issue isn't covered here, please open a GitHub issue with:
- Error message (full output)
- Steps to reproduce
- `terraform version` output
- `aws --version` output
- Relevant configuration (sanitized)
