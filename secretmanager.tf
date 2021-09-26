resource "random_password" "password" {
  length  = 16
  special = false
}


resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "credentials6"
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
  "dbname": "${aws_db_instance.default.name}",
  "efsdnsname": "${aws_efs_file_system.db-efs.dns_name}"
}
EOF
}
