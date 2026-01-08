output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_id" {
  description = "ID of the Application Load Balancer."
  value       = aws_lb.this.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer for Route53 alias records."
  value       = aws_lb.this.zone_id
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = aws_lb_listener.https.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP redirect listener (if created)."
  value       = var.enable_http_redirect ? aws_lb_listener.http[0].arn : null
}

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group for CloudWatch metrics."
  value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_name" {
  description = "Name of the target group."
  value       = aws_lb_target_group.this.name
}

output "security_group_id" {
  description = "ID of the created security group (null if user-provided security groups were used)."
  value       = local.create_security_group ? aws_security_group.this[0].id : null
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB for CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}
