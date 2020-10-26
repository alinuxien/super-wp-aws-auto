resource "aws_security_group" "allow-ssh-local" {
  name        = "allow-ssh-local"
  description = "Autoriser le traffic SSH LOCAL entrant et sortant"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH depuis le VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Aucune connexion sortante"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh-local"
  }
}

resource "tls_private_key" "webserver" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "webserver_key_name"
  public_key = tls_private_key.webserver.public_key_openssh
}

resource "aws_instance" "webserver1" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-webserver
  subnet_id              = aws_subnet.private-a1.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-local.id]
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
  vpc_security_group_ids = [aws_security_group.allow-ssh-local.id]
  availability_zone      = data.aws_availability_zones.available.names[1]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "webserver2"
  }
}

