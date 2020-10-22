resource "aws_instance" "webserver" {
  ami           = var.ami-webserver
  instance_type = var.instance-type-webserver
  subnet_id     = aws_subnet.private-a.id
  tags = {
    Name = "webserver"
  }
}

