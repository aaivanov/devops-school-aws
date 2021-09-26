provider "aws" {
  region = var.settings.region
  access_key = var.access_keys.access_key_id
  secret_key = var.access_keys.Secret_access_key
}

resource "aws_launch_template" "prod_launch_temp" {
  name_prefix   = "${var.settings.tag_prefix}_temp"
  image_id      = var.settings.ami
  instance_type = var.settings.instance_type
  vpc_security_group_ids = [ aws_security_group.allow_http.id, aws_vpc.main_vpc.default_security_group_id ]

  iam_instance_profile {
    name = aws_iam_instance_profile.get_secret_role_profile.name
  }

  user_data = filebase64("${path.module}/install_apache2.sh")
}

resource "aws_autoscaling_group" "autoscaling_grp" {
  vpc_zone_identifier = [aws_subnet.subnet_b.id, aws_subnet.subnet_a.id ]
  load_balancers = [ aws_elb.prod_lb.id ]
  desired_capacity   = var.settings.instance_min_count
  max_size           = 4
  min_size           = var.settings.instance_min_count

  launch_template {
    id      = aws_launch_template.prod_launch_temp.id
    version = "$Latest"
  }

  depends_on = [aws_db_instance.default]
}

resource "aws_autoscaling_attachment" "aautoscaling_grp_attach" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_grp.id
  elb                    = aws_elb.prod_lb.id 
}

resource "aws_iam_instance_profile" "get_secret_role_profile" {
  name = "get_secret_role_profile"
  role = aws_iam_role.get_secret_role.name
}


resource "aws_iam_role" "get_secret_role" {
  name = "get_secret_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_policy" "get_secret_policy" {
  name = "get_secret_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:ListSecrets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.get_secret_role.name
  policy_arn = aws_iam_policy.get_secret_policy.arn
}