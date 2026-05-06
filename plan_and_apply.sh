#!/bin/bash
cd /mnt/c/Users/HP\ ELITEBOOK/Downloads/coalfire-assessment/terraform/environments/dev

echo "=== Running terraform plan to update infrastructure with SSH key ==="
terraform plan

echo ""
echo "=== If the plan looks good, run the following command to apply changes ==="
echo "terraform apply"
