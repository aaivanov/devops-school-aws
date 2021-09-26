resource "aws_efs_file_system" "db-efs" {
  creation_token = "my-product"
 # security_groups = [ aws_vpc.main_vpc.default_security_group_id ]

  tags = {
    Name = "db-efs"
  }
}

resource "aws_efs_mount_target" "subnet_b" {
  file_system_id = aws_efs_file_system.db-efs.id
  subnet_id      = aws_subnet.subnet_b.id
}

resource "aws_efs_mount_target" "subnet_a" {
  file_system_id = aws_efs_file_system.db-efs.id
  subnet_id      = aws_subnet.subnet_a.id
}