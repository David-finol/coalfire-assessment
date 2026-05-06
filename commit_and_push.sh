#!/bin/bash
cd /mnt/c/Users/HP\ ELITEBOOK/Downloads/coalfire-assessment

echo "=== Committing backend configuration changes ==="
git add -A
git commit -m "Enable S3 backend for shared state between local and CI/CD

- Uncomment S3 backend configuration in terraform/environments/dev/main.tf
- This ensures GitHub Actions uses the same state as local deployments
- Fixes 'resource already exists' errors in CI/CD"

echo "=== Pushing changes to trigger GitHub Actions ==="
git push

echo ""
echo "✓ Changes pushed successfully!"
echo "GitHub Actions should now use the same state backend and avoid 'already exists' errors."