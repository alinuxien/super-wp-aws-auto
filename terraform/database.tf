resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private-a2.id, aws_subnet.private-b2.id]

  tags = {
    Name = "Groupe de sous-réseaux de la BDD"
  }
}

resource "aws_security_group" "db" {
  name        = "database"
  description = "Security Group de la BDD"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "autorise le traffic MySQL entrant depuis le VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "autorise le traffic MYSQL sortant vers le VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "database"
  }
}


resource "aws_db_instance" "database" {
  allocated_storage      = 20
  max_allocated_storage  = 1000
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.20"
  instance_class         = "db.t2.micro"
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  name                   = var.database-name
  username               = var.database-username
  password               = var.database-password
  tags = {
    Name = var.website_title
  }
}

