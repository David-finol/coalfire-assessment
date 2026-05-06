output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "ALB security group ID"
}

output "app_asg_sg_id" {
  value       = aws_security_group.app_asg.id
  description = "Application ASG security group ID"
}

output "management_sg_id" {
  value       = aws_security_group.management.id
  description = "Management security group ID"
}
