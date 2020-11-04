provider "aws" {
  region = "eu-west-3"
}

provider "aws" {
  # us-east-1 instance
  region = "us-east-1"
  alias  = "use1"
}

data "aws_availability_zones" "available" {}

data "local_file" "local-pub-key" {
  filename = var.public_key_file
}

data "aws_acm_certificate" "mllec_cloudfront" {
  provider = aws.use1
  domain   = "mllec.akrour.fr"
}

data "aws_acm_certificate" "mllec" {
  domain = "mllec.akrour.fr"
}

data "aws_route53_zone" "primary" {
  name = "mllec.akrour.fr"
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = data.local_file.local-pub-key.content
}
