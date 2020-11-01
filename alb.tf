resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Autoriser le traffic HTTP entrant"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP depuis partout"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP vers partout"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb"
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-a.id, aws_subnet.public-b.id]

  tags = {
    name = "mllec-alb"
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "webserver-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
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

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

