resource "aws_elasticache_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private-a2.id, aws_subnet.private-b2.id]
}

resource "aws_security_group" "cache" {
  name        = "cache"
  description = "Security Group de Elastic Cache"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "autorise le traffic MemCached entrant depuis le VPC"
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "autorise le traffic MemCached sortant vers le VPC"
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "MemCached"
  }
}


resource "aws_elasticache_cluster" "cache" {
  cluster_id           = "cache-cluster"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.cache.id]
  apply_immediately    = true
}
