resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Autoriser le traffic HTTPS entrant"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS depuis partout"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Aucun acces vers l exterieur"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "webserver-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.private-a1.id,aws_subnet.private-a2.id]

  tags = {
    name = "mllec-alb"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "tg-webserver1" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg-webserver2" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

