#Target Groups
resource "aws_lb_target_group" "tg_a" {
  name     = "tg-a"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "tg_b" {
  name     = "tg-b"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

#Target Group Attachment
resource "aws_lb_target_group_attachment" "tg_attach_a" {
  target_group_arn = aws_lb_target_group.tg_a.arn
  target_id        = aws_instance.amazon_linux_lb1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attach_b" {
  target_group_arn = aws_lb_target_group.tg_b.arn
  target_id        = aws_instance.amazon_linux_lb2.id
  port             = 80
}

#Load Balancer
resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id] #for internet-facing LB (internal=false): At least two subnets in two different Availability Zones must be specified
}

#Listener
resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api_cert.arn #certificate for HTTPS
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg_a.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.tg_b.arn
        weight = 100
      }
    }
  }
}

#Security Group LB
resource "aws_security_group" "lb" {
  name        = "lb_web"
  description = "allow web traffic"
  vpc_id      = aws_vpc.main.id
}
#ingress rule for Security Group
resource "aws_vpc_security_group_ingress_rule" "lb_allow_443" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
#ingress rule for Security Group
resource "aws_vpc_security_group_ingress_rule" "lb_allow_80" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
#egress rule for Security Group
resource "aws_vpc_security_group_egress_rule" "lb_egress_all" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

