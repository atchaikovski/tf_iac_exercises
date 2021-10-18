
# для нормальной работы нескольких приложений нужен балансировщик, который будет 
# принимать запросы и распределять их в зависимости от целевого приложения 
#
resource "aws_lb" "example" {
  name               = "terraform-aws-lb-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  # группа безопасности, которая описывает доступы
  security_groups    = [aws_security_group.alb.id]
  tags = {
    Name = "aws-LB-example"
  }
}

# это listener балансировщика (в данном случае ALB)
# сидит на 80 порту и принимает HTTP
#
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  # По умолчанию возвращает простую страницу с кодом 404
  default_action {
    type = "fixed-response"
     fixed_response {
       content_type = "text/plain"
       message_body = "404: page not found"
       status_code  = 404
     } 
   }
   tags = {
     Name = "aws-LB-listener-example"
   }
}

# описание правила реагирования для listener.  
#
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# это описание целевой группы ALB (балансировщика)
#
resource "aws_lb_target_group" "asg" {
  name     = "terraform-ALB-Target-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "aws-LB-TG-example"
  }
}

# по умолчанию все доступы закрыты, так что нужно описать в группе безопасности,
# куда и как будет разрешен/запрещен доступ
#
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  # Разрешаем все входящие HTTP-запросы
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
# Разрешаем все исходящие запросы
   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   } 
   tags = {
     Name = "aws-SG-ALB-example"
   }
}