# Application Load Balancer
resource "aws_lb" "main" {
  name_prefix        = "cfal"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.application_subnet_ids

  enable_deletion_protection = false
  enable_http2               = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb"
    }
  )
}

# Target Group
resource "aws_lb_target_group" "app" {
  name_prefix = "app"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-target-group"
    }
  )
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Optional: HTTPS Listener (requires certificate)
# Uncomment and update certificate_arn to enable HTTPS
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.ssl_certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }
