output "asg_name" {
  value       = aws_autoscaling_group.app.name
  description = "Auto Scaling Group name"
}

output "asg_id" {
  value       = aws_autoscaling_group.app.id
  description = "Auto Scaling Group ID"
}

output "management_instance_id" {
  value       = aws_instance.management.id
  description = "Management instance ID"
}

output "management_instance_public_ip" {
  value       = aws_instance.management.public_ip
  description = "Management instance public IP"
}

output "launch_template_id" {
  value       = aws_launch_template.app.id
  description = "Launch template ID"
}

output "launch_template_name" {
  value       = aws_launch_template.app.name
  description = "Launch template name"
}
