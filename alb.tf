#####
##### AWS LB
#####

resource "aws_lb" "nab_lb" {
  name               = "interview-32-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups    = [aws_security_group.alb.id]


  tags = {
    Name = "interview_32 Load Balancer"
  }
}

resource "aws_alb_target_group" "webserver" {
  # name        = "nab-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  # target_type = "instance"

  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   interval            = 20
  #   timeout             = 5
  #   protocol            = "HTTP"
  #   path                = "/"
  # }
}

resource "aws_alb_listener" "nab_listener" {
  load_balancer_arn = aws_lb.nab_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.webserver.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "rule1" {
  listener_arn = aws_alb_listener.nab_listener.arn
  priority     = 100

    condition {
    path_pattern {
      values = ["/"]
    }
  }


  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }

}




# resource "aws_autoscaling_attachment" "autoscaling_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.mygroup.id
#   lb_target_group_arn    = aws_lb_target_group.nab_target_group.arn
# }