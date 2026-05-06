locals {
  common_tags = {
    Project     = "coalfire-assessment"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
