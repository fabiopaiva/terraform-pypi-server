resource "aws_acm_certificate" "pypi_server" {
  domain_name = var.default_domain
  subject_alternative_names = [format("*.%s", var.default_domain)]
  validation_method = "CNAME"
}
