provider "aws" {
  region = var.settings.region
  access_key = var.access_keys.access_key_id
  secret_key = var.access_keys.Secret_access_key
}

resource "aws_launch_template" "prod_launch_temp" {
  name_prefix   = "${var.settings.tag_prefix}_temp"
  image_id      = var.settings.ami
  instance_type = var.settings.instance_type
  vpc_security_group_ids = [ aws_security_group.allow_http.id ]

  user_data = filebase64("${path.module}/install_apache2.sh")
}

resource "aws_autoscaling_group" "autoscaling_grp" {
  vpc_zone_identifier = [aws_subnet.subnet_b.id, aws_subnet.subnet_a.id ]
  load_balancers = [ aws_elb.prod_lb.id ]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2

  launch_template {
    id      = aws_launch_template.prod_launch_temp.id
    version = "$Latest"

  }
}

resource "aws_autoscaling_attachment" "aautoscaling_grp_attach" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_grp.id
  elb                    = aws_elb.prod_lb.id 
}
