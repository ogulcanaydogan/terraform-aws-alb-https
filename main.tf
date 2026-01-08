locals {
  create_security_group  = length(var.security_group_ids) == 0
  alb_security_group_ids = local.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
  target_group_name      = substr("${var.name}-tg", 0, 32)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = "${var.name}-alb-sg"
  description = "Security group for ${var.name} ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}

resource "aws_lb" "this" {
  name                       = var.name
  load_balancer_type         = "application"
  internal                   = var.internal
  security_groups            = local.alb_security_group_ids
  subnets                    = var.subnet_ids
  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_http2               = var.enable_http2

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "this" {
  name                 = local.target_group_name
  port                 = var.target_port
  protocol             = var.target_protocol
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_duration
      cookie_name     = var.stickiness_type == "app_cookie" ? var.stickiness_cookie_name : null
      enabled         = true
    }
  }

  tags = merge(var.tags, {
    Name = local.target_group_name
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http" {
  count             = var.enable_http_redirect ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
