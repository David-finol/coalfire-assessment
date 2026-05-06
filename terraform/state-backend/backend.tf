# This backend configuration will be used after the state bucket is created
# Uncomment and run `terraform init` after creating the backend infrastructure

# terraform {
#   backend "s3" {
#     bucket         = "coalfire-terraform-state-510674264237"
#     key            = "coalfire/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "coalfire-terraform-locks"
#     encrypt        = true
#   }
# }
