# terraform-aws-alb-https

Terraform module that provisions an Application Load Balancer with an HTTPS listener, optional HTTP to HTTPS redirect, and a target group with configurable health checks. The module can either create a dedicated security group or reuse existing ones.

## Features

- Modern TLS 1.3/1.2 security policy by default
- Configurable health checks with all parameters exposed
- Optional sticky sessions (cookie-based)
- Optional S3 access logging
- HTTP/2 support
- Deletion protection option
- Configurable idle timeout and deregistration delay
- IPv4 and dual-stack (IPv6) support
- Security headers (drop invalid header fields enabled by default)
- Support for instance, IP, and Lambda target types

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Modules

No modules are used.

## Resources

| Name | Type |
|------|------|
| aws_lb.this | resource |
| aws_lb_listener.http | resource |
| aws_lb_listener.https | resource |
| aws_lb_target_group.this | resource |
| aws_security_group.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to use for the ALB and related resources. | `string` | n/a | yes |
| vpc_id | ID of the VPC where the ALB will be deployed. | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ALB. | `list(string)` | n/a | yes |
| certificate_arn | ARN of the ACM certificate for HTTPS. | `string` | n/a | yes |
| tags | Tags to apply to resources. | `map(string)` | `{}` | no |
| internal | If true, the ALB will be internal (not internet-facing). | `bool` | `false` | no |
| ip_address_type | IP address type for the ALB (ipv4 or dualstack). | `string` | `"ipv4"` | no |
| target_port | Port the target group forwards traffic to. | `number` | `80` | no |
| target_protocol | Protocol for the target group (HTTP or HTTPS). | `string` | `"HTTP"` | no |
| target_type | Type of target for the target group (instance, ip, or lambda). | `string` | `"instance"` | no |
| health_check_path | HTTP path for target group health checks. | `string` | `"/"` | no |
| health_check_port | Port for health checks. Use 'traffic-port' to use the target port. | `string` | `"traffic-port"` | no |
| health_check_protocol | Protocol for health checks (HTTP or HTTPS). | `string` | `"HTTP"` | no |
| health_check_interval | Interval in seconds between health checks. | `number` | `30` | no |
| health_check_timeout | Timeout in seconds for health check responses. | `number` | `5` | no |
| health_check_healthy_threshold | Number of consecutive successful health checks required. | `number` | `3` | no |
| health_check_unhealthy_threshold | Number of consecutive failed health checks required. | `number` | `3` | no |
| health_check_matcher | HTTP status codes to use for successful response. | `string` | `"200"` | no |
| enable_http_redirect | Create an HTTP listener that redirects to HTTPS. | `bool` | `true` | no |
| ssl_policy | SSL policy for the HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| idle_timeout | Time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| enable_deletion_protection | Enable deletion protection for the ALB. | `bool` | `false` | no |
| drop_invalid_header_fields | Drop HTTP headers with invalid header fields. | `bool` | `true` | no |
| enable_http2 | Enable HTTP/2 support. | `bool` | `true` | no |
| deregistration_delay | Time in seconds to wait before deregistering a target. | `number` | `300` | no |
| slow_start | Time in seconds for targets to warm up before receiving full traffic. | `number` | `0` | no |
| enable_stickiness | Enable sticky sessions for the target group. | `bool` | `false` | no |
| stickiness_type | Type of sticky sessions (lb_cookie or app_cookie). | `string` | `"lb_cookie"` | no |
| stickiness_duration | Duration of sticky sessions in seconds. | `number` | `86400` | no |
| stickiness_cookie_name | Name of the application cookie for app_cookie stickiness type. | `string` | `null` | no |
| enable_access_logs | Enable ALB access logging to S3. | `bool` | `false` | no |
| access_logs_bucket | S3 bucket name for ALB access logs. | `string` | `""` | no |
| access_logs_prefix | S3 prefix for ALB access logs. | `string` | `""` | no |
| ingress_cidrs | CIDR blocks allowed to access the ALB. | `list(string)` | `["0.0.0.0/0"]` | no |
| security_group_ids | Existing security group IDs to associate with the ALB. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | ARN of the Application Load Balancer. |
| alb_id | ID of the Application Load Balancer. |
| alb_dns_name | DNS name of the Application Load Balancer. |
| alb_zone_id | Hosted zone ID of the Application Load Balancer. |
| alb_arn_suffix | ARN suffix of the ALB for CloudWatch metrics. |
| https_listener_arn | ARN of the HTTPS listener. |
| http_listener_arn | ARN of the HTTP redirect listener (if created). |
| target_group_arn | ARN of the target group. |
| target_group_arn_suffix | ARN suffix of the target group for CloudWatch metrics. |
| target_group_name | Name of the target group. |
| security_group_id | ID of the created security group (if created). |

## Usage

### Basic Example

```hcl
module "alb" {
  source = "path/to/terraform-aws-alb-https"

  name            = "my-app-alb"
  vpc_id          = "vpc-1234567890abcdef0"
  subnet_ids      = ["subnet-aaa111bbb222ccc33", "subnet-ddd444eee555fff66"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890-abcd-ef1234567890"

  tags = {
    Project     = "my-app"
    Environment = "production"
  }
}
```

### Advanced Example with Custom Health Checks and Sticky Sessions

```hcl
module "alb" {
  source = "path/to/terraform-aws-alb-https"

  name            = "my-app-alb"
  vpc_id          = "vpc-1234567890abcdef0"
  subnet_ids      = ["subnet-aaa111bbb222ccc33", "subnet-ddd444eee555fff66"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890-abcd-ef1234567890"

  # Target group settings
  target_port     = 8080
  target_protocol = "HTTP"
  target_type     = "ip"

  # Custom health check
  health_check_path              = "/health"
  health_check_interval          = 15
  health_check_timeout           = 5
  health_check_healthy_threshold = 2
  health_check_matcher           = "200-299"

  # Sticky sessions
  enable_stickiness   = true
  stickiness_type     = "lb_cookie"
  stickiness_duration = 3600

  # ALB settings
  idle_timeout               = 120
  enable_deletion_protection = true
  deregistration_delay       = 60

  # Restrict access
  ingress_cidrs = ["10.0.0.0/8"]

  tags = {
    Project     = "my-app"
    Environment = "production"
  }
}
```

### Example with Access Logging

```hcl
module "alb" {
  source = "path/to/terraform-aws-alb-https"

  name            = "my-app-alb"
  vpc_id          = "vpc-1234567890abcdef0"
  subnet_ids      = ["subnet-aaa111bbb222ccc33", "subnet-ddd444eee555fff66"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890-abcd-ef1234567890"

  # Enable access logs
  enable_access_logs = true
  access_logs_bucket = "my-alb-logs-bucket"
  access_logs_prefix = "my-app-alb"

  tags = {
    Project     = "my-app"
    Environment = "production"
  }
}
```

### Route53 Integration

Use the outputs to create a Route53 alias record:

```hcl
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "app.example.com"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
```

See the [examples/basic](./examples/basic) directory for a full configuration including provider setup and outputs.

## Security Considerations

- The default SSL policy (`ELBSecurityPolicy-TLS13-1-2-2021-06`) supports TLS 1.3 and TLS 1.2 only
- `drop_invalid_header_fields` is enabled by default to protect against HTTP request smuggling
- Consider restricting `ingress_cidrs` from the default `0.0.0.0/0` in production environments
- Enable `enable_access_logs` for compliance and security auditing in production
