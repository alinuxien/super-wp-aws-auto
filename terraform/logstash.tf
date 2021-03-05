resource "aws_security_group" "logstash" {
  name        = "logstash"
  description = "Groupe de Securite de LogStash"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "logstash"
  }
}

resource "aws_security_group_rule" "in-ssh-logstash" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.logstash.id
}

resource "aws_security_group_rule" "in-beats" {
  type              = "ingress"
  from_port         = 5044
  to_port           = 5044
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.logstash.id
}

resource "aws_security_group_rule" "in-https-logstash" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.logstash.id
}

resource "aws_security_group_rule" "out-anywhere" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.logstash.id
}

resource "aws_instance" "logstash1" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-logstash
  subnet_id              = aws_subnet.private-a2.id
  vpc_security_group_ids = [aws_security_group.logstash.id]
  key_name               = aws_key_pair.keypair.id
  tags = {
    Name = "logstash1"
  }
}

resource "aws_instance" "logstash2" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-logstash
  subnet_id              = aws_subnet.private-b2.id
  vpc_security_group_ids = [aws_security_group.logstash.id]
  key_name               = aws_key_pair.keypair.id
  tags = {
    Name = "logstash2"
  }
}

