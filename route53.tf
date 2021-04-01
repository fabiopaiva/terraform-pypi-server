data "aws_route53_zone" "default" {
  name = var.default_domain
}
