output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "application_subnet_ids" {
  value       = aws_subnet.application[*].id
  description = "Application subnet IDs"
}

output "management_subnet_id" {
  value       = aws_subnet.management.id
  description = "Management subnet ID"
}

output "backend_subnet_ids" {
  value       = aws_subnet.backend[*].id
  description = "Backend subnet IDs"
}

output "igw_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}
