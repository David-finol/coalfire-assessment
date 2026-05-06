variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.1.0.0/16"
}

variable "application_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for application subnets"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "management_subnet_cidr" {
  type        = string
  description = "CIDR block for management subnet"
  default     = "10.1.3.0/24"
}

variable "backend_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for backend subnets"
  default     = ["10.1.4.0/24", "10.1.5.0/24"]
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
  
  validation {
    condition     = var.asg_min_size >= 2
    error_message = "Minimum ASG size must be at least 2."
  }
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in ASG"
  default     = 6
  
  validation {
    condition     = var.asg_max_size <= 6
    error_message = "Maximum ASG size cannot exceed 6."
  }
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in ASG"
  default     = 2
}

variable "management_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH to management instance (update this with your IP)"
  default     = ["0.0.0.0/32"] # Change this to your IP or network - e.g., "203.0.113.0/24"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH access"
  default     = ""
}
