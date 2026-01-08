variable "name" {
  description = "Name to use for the ALB and related resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 32
    error_message = "name must be between 1 and 32 characters."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed."
  type        = string

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id cannot be empty."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required."
  }
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:acm:[a-z0-9-]+:\\d{12}:certificate/[-a-z0-9]+$", var.certificate_arn))
    error_message = "certificate_arn must be a valid ACM certificate ARN."
  }
}

variable "target_port" {
  description = "Port the target group forwards traffic to."
  type        = number
  default     = 80

  validation {
    condition     = var.target_port > 0 && var.target_port <= 65535
    error_message = "target_port must be between 1 and 65535."
  }
}

variable "target_protocol" {
  description = "Protocol for the target group (HTTP or HTTPS)."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "target_protocol must be either HTTP or HTTPS."
  }
}

variable "target_type" {
  description = "Type of target for the target group (instance, ip, or lambda)."
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda"], var.target_type)
    error_message = "target_type must be instance, ip, or lambda."
  }
}

variable "health_check_path" {
  description = "HTTP path for target group health checks."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with '/'."
  }
}

variable "health_check_port" {
  description = "Port for health checks. Use 'traffic-port' to use the target port."
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health checks (HTTP or HTTPS)."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check_protocol)
    error_message = "health_check_protocol must be either HTTP or HTTPS."
  }
}

variable "health_check_interval" {
  description = "Interval in seconds between health checks."
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Timeout in seconds for health check responses."
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "health_check_timeout must be between 2 and 120 seconds."
  }
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required to mark target healthy."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "health_check_healthy_threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required to mark target unhealthy."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "health_check_unhealthy_threshold must be between 2 and 10."
  }
}

variable "health_check_matcher" {
  description = "HTTP status codes to use when checking for a successful response."
  type        = string
  default     = "200"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "enable_http_redirect" {
  description = "Create an HTTP listener that redirects to HTTPS."
  type        = bool
  default     = true
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to access the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.ingress_cidrs) > 0
    error_message = "ingress_cidrs must include at least one CIDR block."
  }
}

variable "security_group_ids" {
  description = "Existing security group IDs to associate with the ALB. If empty, a new security group is created."
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener. Use TLS 1.2+ policies for security."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  validation {
    condition     = startswith(var.ssl_policy, "ELBSecurityPolicy")
    error_message = "ssl_policy must be a valid ELB security policy name."
  }
}

variable "internal" {
  description = "If true, the ALB will be internal (not internet-facing)."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "idle_timeout must be between 1 and 4000 seconds."
  }
}

variable "drop_invalid_header_fields" {
  description = "Drop HTTP headers with invalid header fields. Recommended for security."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2 support."
  type        = bool
  default     = true
}

variable "deregistration_delay" {
  description = "Time in seconds to wait before deregistering a target."
  type        = number
  default     = 300

  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600 seconds."
  }
}

variable "slow_start" {
  description = "Time in seconds for targets to warm up before receiving full traffic share."
  type        = number
  default     = 0

  validation {
    condition     = var.slow_start >= 0 && var.slow_start <= 900
    error_message = "slow_start must be between 0 and 900 seconds."
  }
}

variable "enable_stickiness" {
  description = "Enable sticky sessions for the target group."
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of sticky sessions (lb_cookie or app_cookie)."
  type        = string
  default     = "lb_cookie"

  validation {
    condition     = contains(["lb_cookie", "app_cookie"], var.stickiness_type)
    error_message = "stickiness_type must be either lb_cookie or app_cookie."
  }
}

variable "stickiness_duration" {
  description = "Duration of sticky sessions in seconds."
  type        = number
  default     = 86400

  validation {
    condition     = var.stickiness_duration >= 1 && var.stickiness_duration <= 604800
    error_message = "stickiness_duration must be between 1 and 604800 seconds (7 days)."
  }
}

variable "stickiness_cookie_name" {
  description = "Name of the application cookie for app_cookie stickiness type."
  type        = string
  default     = null
}

variable "enable_access_logs" {
  description = "Enable ALB access logging to S3."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs."
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = ""
}

variable "ip_address_type" {
  description = "IP address type for the ALB (ipv4 or dualstack)."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be either ipv4 or dualstack."
  }
}
