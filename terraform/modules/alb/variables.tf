variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "application_subnet_ids" {
  type        = list(string)
  description = "List of application subnet IDs"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "target_port" {
  type        = number
  description = "Port for target group"
  default     = 80
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Project = "coalfire-assessment"
  }
}
