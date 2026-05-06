#!/bin/bash
cd /mnt/c/Users/HP\ ELITEBOOK/Downloads/coalfire-assessment/terraform/environments/dev

echo "=== Checking for local state files ==="
if [ -f "terraform.tfstate" ]; then
    echo "Found local terraform.tfstate file"
    echo "=== Migrating local state to S3 backend ==="
    terraform init -migrate-state
    echo "State migration complete"
else
    echo "No local state file found - initializing with S3 backend"
    terraform init
fi

echo ""
echo "=== Current state backend status ==="
terraform state list | head -10

echo ""
echo "=== Ready for GitHub Actions deployment ==="
echo "Commit and push the changes to trigger CI/CD"