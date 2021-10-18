resource "aws_launch_configuration" "example" {
  #image_id        = "ami-0c55b159cbfafe1f0"
  image_id = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World from Alex T. " > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
   
    lifecycle {
        create_before_destroy = true
  }
}

# группа автомасштабирования. следит за тем, чтобы ресурсов было в достатке и соотв конфигурации
#
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "EC2 httpd with ASG"
    propagate_at_launch = true
  } 
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}
