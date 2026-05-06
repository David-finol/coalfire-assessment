# User data script for Apache installation
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_port = var.app_port
  }))
}

# Launch template for ASG
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-lt-"
  image_id      = data.aws_ami.linux.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_security_group_id]
    delete_on_termination       = true
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-app-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-app-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.environment}-app-asg"
  vpc_zone_identifier = var.application_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-app-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [var.target_group_arn]
}

# IAM Role for EC2 instances
resource "aws_iam_role" "app" {
  name_prefix = "${var.environment}-app-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-app-role"
    }
  )
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "app_cloudwatch" {
  name_prefix = "${var.environment}-app-cw-"
  role        = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "app" {
  name_prefix = "${var.environment}-app-profile-"
  role        = aws_iam_role.app.name
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Management EC2 Instance
resource "aws_instance" "management" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  subnet_id              = var.management_subnet_id
  vpc_security_group_ids = [var.management_security_group_id]
  associate_public_ip_address = true
  key_name               = var.key_name != "" ? var.key_name : null

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-management-instance"
    }
  )
}
