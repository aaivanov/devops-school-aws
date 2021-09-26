resource "aws_db_instance" "default" {
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = random_password.password.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.prod_db.name
  allocated_storage     = 5
  max_allocated_storage = 10
}

resource "aws_db_subnet_group" "prod_db" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet_b.id, aws_subnet.subnet_a.id ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "random_password" "password" {
  length  = 16
  special = false
}


resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "credentials0"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_db_instance.default.username}",
  "password": "${random_password.password.result}",
  "engine": "${aws_db_instance.default.engine}",
  "host": "${aws_db_instance.default.address}",
  "port": "${aws_db_instance.default.port}",
  "dbname": "${aws_db_instance.default.name}" 
}
EOF
}
