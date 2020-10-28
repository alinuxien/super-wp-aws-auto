provider "aws" {
  region = "eu-west-3"
}

data "aws_availability_zones" "available" {}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = var.aws-local-pub-key
}
