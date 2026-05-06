output "vpc_id" {
  value       = module.networking.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.networking.vpc_cidr
  description = "VPC CIDR block"
}

output "application_subnet_ids" {
  value       = module.networking.application_subnet_ids
  description = "Application subnet IDs"
}

output "management_subnet_id" {
  value       = module.networking.management_subnet_id
  description = "Management subnet ID"
}

output "backend_subnet_ids" {
  value       = module.networking.backend_subnet_ids
  description = "Backend subnet IDs"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the ALB"
}

output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ARN of the ALB"
}

output "asg_name" {
  value       = module.compute.asg_name
  description = "Name of the Auto Scaling Group"
}

output "management_instance_id" {
  value       = module.compute.management_instance_id
  description = "Management instance ID"
}

output "management_instance_public_ip" {
  value       = module.compute.management_instance_public_ip
  description = "Management instance public IP (use this to SSH)"
}

output "alb_sg_id" {
  value       = module.security.alb_sg_id
  description = "ALB security group ID"
}

output "app_asg_sg_id" {
  value       = module.security.app_asg_sg_id
  description = "Application ASG security group ID"
}

output "management_sg_id" {
  value       = module.security.management_sg_id
  description = "Management security group ID"
}
