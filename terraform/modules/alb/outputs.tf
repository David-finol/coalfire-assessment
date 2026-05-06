output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "ALB Zone ID"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "Target group ARN"
}

output "target_group_name" {
  value       = aws_lb_target_group.app.name
  description = "Target group name"
}
