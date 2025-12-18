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

variable "health_check_path" {
  description = "HTTP path for target group health checks."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with '/'."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
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
