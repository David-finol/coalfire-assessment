variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state"
  default     = "coalfire-terraform-state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
  default     = "coalfire-terraform-locks"
}
