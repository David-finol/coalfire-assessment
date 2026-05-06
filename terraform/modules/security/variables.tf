variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "management_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH to management instance"
  default     = ["0.0.0.0/32"] # Change this to your IP or network
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Project = "coalfire-assessment"
  }
}
