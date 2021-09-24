resource "aws_elb" "prod_lb" {
  name               = "${var.settings.tag_prefix}-elb"
  subnets = [aws_subnet.subnet_b.id, aws_subnet.subnet_a.id ]
  security_groups =  [ aws_security_group.allow_http.id ]

#  access_logs {
#    bucket        = "foo"
#    bucket_prefix = "bar"
#    interval      = 60
#  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  #instances                   = [aws_instance.instance_b.id, aws_instance.instance_a.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.settings.tag_prefix}_elb"
  }
}