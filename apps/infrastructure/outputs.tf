data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "account_arn" {
  value = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public.id, aws_subnet.public_b.id]
}

output "ecr_api_url" {
  value = aws_ecr_repository.api.repository_url
}

output "ecr_web_url" {
  value = aws_ecr_repository.web.repository_url
}

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "host:port for connecting to RDS"
}

output "rds_address" {
  value       = aws_db_instance.main.address
  description = "host only (no port) — used in Prisma DATABASE_URL"
}

output "rds_database_url" {
  value       = "postgresql://${aws_db_instance.main.username}:${var.db_password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}?sslmode=require"
  description = "Ready-to-use connection string for Prisma"
  sensitive   = true
}

output "ec2_public_ip" {
  value       = aws_instance.app.public_ip
  description = "EC2 public IP — use for SSH and app URLs"
}

output "app_web_url" {
  value       = "http://${aws_instance.app.public_ip}:3000"
  description = "Next.js frontend URL"
}

output "app_api_url" {
  value       = "http://${aws_instance.app.public_ip}:8080"
  description = "NestJS API URL"
}

output "ci_public_ip" {
  value       = aws_instance.ci.public_ip
  description = "Woodpecker CI public IP"
}

output "ci_url" {
  value       = "http://${aws_instance.ci.public_ip}:8000"
  description = "Woodpecker CI URL"
}
