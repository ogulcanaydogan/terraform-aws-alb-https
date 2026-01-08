module "alb" {
  source = "../.."

  name            = "example-alb"
  vpc_id          = "vpc-1234567890abcdef0"
  subnet_ids      = ["subnet-aaa111bbb222ccc33", "subnet-ddd444eee555fff66"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890-abcd-ef1234567890"

  tags = {
    Project     = "sample"
    Environment = "dev"
  }
}
