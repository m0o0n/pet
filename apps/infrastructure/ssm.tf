resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.project}/database_url"
  type  = "SecureString"
  value = "postgresql://postgres:${var.db_password}@${aws_db_instance.main.endpoint}/petproject?sslmode=require"

  tags = {
    Name = "${var.project}-database-url"
  }
}
