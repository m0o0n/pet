variable "aws_region" {
  default = "eu-central-1"
}

variable "project" {
  default = "pet-project"
}

variable "db_password" {
  description = "Master password for RDS Postgres"
  type        = string
  sensitive   = true
}

variable "allowed_db_ips" {
  description = "CIDR blocks allowed to connect to RDS on port 5432"
  type        = list(string)
}

variable "ssh_public_key" {
  description = "SSH public key placed on EC2 for access"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "CIDR blocks allowed to SSH into EC2"
  type        = list(string)
}

variable "woodpecker_github_secret" {
  description = "GitHub OAuth App client secret for Woodpecker CI"
  type        = string
  sensitive   = true
}
