output "alb_dns_name" {
  description = "DNS name of the example ALB."
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ARN of the example target group."
  value       = module.alb.target_group_arn
}
