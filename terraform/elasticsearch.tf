data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_security_group" "es" {
  name        = "elastic"
  description = "Autoriser le traffic HTTPS entrant et sortant"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }
  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }
  tags = {
    Name = "elastic"
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.es-domain
  elasticsearch_version = "7.9"

  cluster_config {
    instance_type          = var.instance-type-elasticsearch
    instance_count         = "2"
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 2
    }
    dedicated_master_enabled = false
    warm_enabled             = false
  }

  vpc_options {
    subnet_ids         = [aws_subnet.private-a2.id, aws_subnet.private-b2.id]
    security_group_ids = [aws_security_group.es.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "10"
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.es-domain}/*"
        }
    ]
  }
CONFIG

  tags = {
    Domain = "es.mllec.akrour.fr"
  }

  depends_on = [aws_vpc.main, aws_iam_service_linked_role.es]
}
