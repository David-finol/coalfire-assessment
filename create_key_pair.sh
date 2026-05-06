#!/bin/bash
set -e

# Source bash profile to get AWS CLI in PATH
source ~/.bashrc 2>/dev/null || true

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Create the key pair (try snap path first, then regular path)
if command -v /snap/bin/aws &> /dev/null; then
  /snap/bin/aws ec2 create-key-pair --key-name coalfire-assessment --region us-east-1 --query 'KeyMaterial' --output text > ~/.ssh/coalfire-assessment.pem
elif command -v aws &> /dev/null; then
  aws ec2 create-key-pair --key-name coalfire-assessment --region us-east-1 --query 'KeyMaterial' --output text > ~/.ssh/coalfire-assessment.pem
else
  echo "ERROR: AWS CLI not found"
  exit 1
fi

# Set proper permissions
chmod 600 ~/.ssh/coalfire-assessment.pem

echo "✓ Key pair 'coalfire-assessment' created successfully"
echo "✓ Key saved to ~/.ssh/coalfire-assessment.pem"
ls -lh ~/.ssh/coalfire-assessment.pem
