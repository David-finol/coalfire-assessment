variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in ASG"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in ASG"
  default     = 6
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in ASG"
  default     = 2
}

variable "app_port" {
  type        = number
  description = "Port for application"
  default     = 80
}

variable "application_subnet_ids" {
  type        = list(string)
  description = "List of application subnet IDs"
}

variable "management_subnet_id" {
  type        = string
  description = "Management subnet ID"
}

variable "app_security_group_id" {
  type        = string
  description = "Security group ID for application instances"
}

variable "management_security_group_id" {
  type        = string
  description = "Security group ID for management instance"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN for ALB"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Project = "coalfire-assessment"
  }
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH access"
  default     = ""
}
