resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.project}/database_url"
  type  = "SecureString"
  value = "postgresql://postgres:${var.db_password}@${aws_db_instance.main.endpoint}/petproject?sslmode=require"

  tags = {
    Name = "${var.project}-database-url"
  }
}

resource "random_password" "woodpecker_agent_secret" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "woodpecker_github_secret" {
  name  = "/${var.project}/woodpecker_github_secret"
  type  = "SecureString"
  value = var.woodpecker_github_secret

  tags = {
    Name = "${var.project}-woodpecker-github-secret"
  }
}

resource "aws_ssm_parameter" "woodpecker_agent_secret" {
  name  = "/${var.project}/woodpecker_agent_secret"
  type  = "SecureString"
  value = random_password.woodpecker_agent_secret.result

  tags = {
    Name = "${var.project}-woodpecker-agent-secret"
  }
}
