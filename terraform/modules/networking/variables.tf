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

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Project = "coalfire-assessment"
  }
}
