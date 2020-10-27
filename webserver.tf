resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Groupe de Securite du WebServer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group_rule" "in-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group_rule" "in-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group_rule" "out-null" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.webserver.id
}

resource "tls_private_key" "webserver" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "webserver_key_name"
  public_key = tls_private_key.webserver.public_key_openssh
}

resource "aws_instance" "webserver1" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-webserver
  subnet_id              = aws_subnet.private-a1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  availability_zone      = data.aws_availability_zones.available.names[0]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-webserver
  subnet_id              = aws_subnet.private-a2.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  availability_zone      = data.aws_availability_zones.available.names[1]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "webserver2"
  }
}

output webserver1_ip {
  value = aws_instance.webserver1.private_ip
}

output webserver2_ip {
  value = aws_instance.webserver2.private_ip
}

output webservers_private_key {
  value = tls_private_key.webserver.private_key_pem
}

output webservers_public_key {
  value = tls_private_key.webserver.public_key_openssh
}
