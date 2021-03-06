resource "aws_security_group" "allow-ssh" {
  name        = "bastion"
  description = "Security Group du Bastion SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "autorise le SSH entrant depuis partout"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "autorise le SSH sortant vers le VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami-bastion
  instance_type               = var.instance-type-bastion
  subnet_id                   = aws_subnet.public-b.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow-ssh.id]
  key_name                    = aws_key_pair.keypair.id
  tags = {
    Name = "bastion"
  }
}

