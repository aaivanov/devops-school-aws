resource "aws_security_group" "allow_http" {
  name        = "${var.settings.tag_prefix}_allow_http"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.settings.tag_prefix}_allow_http"
  }
}

resource "aws_security_group_rule" "ingress_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "ingress_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["3.120.181.0/24"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}