variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_assume_role" {
  type = string
}

variable "default_domain" {
  default = "account-1.aws-tests.skyworkz.nl"
}
