terraform {
  backend "s3" {
    bucket         = "skyworkz-assignments-tfstate"
    key            = "fabio-test/terraform.tfstate"
    dynamodb_table = "skyworkz-assignments-tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}
