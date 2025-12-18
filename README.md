# terraform-aws-alb-https

Terraform module that provisions an Application Load Balancer with an HTTPS listener, optional HTTP to HTTPS redirect, and a target group with health checks. The module can either create a dedicated security group or reuse existing ones.

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
| target_port | Port the target group forwards traffic to. | `number` | `80` | no |
| health_check_path | HTTP path for target group health checks. | `string` | `"/"` | no |
| tags | Tags to apply to resources. | `map(string)` | n/a | yes |
| enable_http_redirect | Create an HTTP listener that redirects to HTTPS. | `bool` | `true` | no |
| ingress_cidrs | CIDR blocks allowed to access the ALB. | `list(string)` | `["0.0.0.0/0"]` | no |
| security_group_ids | Existing security group IDs to associate with the ALB. If empty, a new security group is created. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | ARN of the Application Load Balancer. |
| alb_dns_name | DNS name of the Application Load Balancer. |
| alb_zone_id | Hosted zone ID of the Application Load Balancer. |
| https_listener_arn | ARN of the HTTPS listener. |
| target_group_arn | ARN of the target group. |
| security_group_id | ID of the created security group (if created). |

## Example

```hcl
module "alb" {
  source = "../.."

  name            = "example-alb"
  vpc_id          = "vpc-1234567890abcdef0"
  subnet_ids      = ["subnet-aaa111bbb222ccc33", "subnet-ddd444eee555fff66"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890-abcd-ef1234567890"
  tags = {
    Project = "sample"
    Env     = "dev"
  }
}
```

See the [examples/basic](./examples/basic) directory for a full configuration including provider setup and outputs.
