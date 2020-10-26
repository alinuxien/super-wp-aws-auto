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

resource "aws_key_pair" "webserver" {
  key_name   = "webserver-key"
  public_key = var.aws-local-pub-key
}


resource "aws_instance" "webserver" {
  ami                    = var.ami-webserver
  instance_type          = var.instance-type-webserver
  subnet_id              = aws_subnet.private-a.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-local.id]
  key_name               = aws_key_pair.webserver.id
  tags = {
    Name = "webserver"
  }
}

