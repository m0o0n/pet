#!/bin/bash
set -euo pipefail

AWS_REGION="${aws_region}"
ECR_REGISTRY="${ecr_registry}"
PROJECT="${project}"

# Add official Docker apt repository
apt-get update -y
apt-get install -y ca-certificates curl gnupg awscli
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
usermod -aG docker ubuntu

# Login to ECR using the instance IAM role
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Fetch DATABASE_URL from SSM (no plaintext in user-data)
DATABASE_URL=$(aws ssm get-parameter \
  --region "$AWS_REGION" \
  --name "/$PROJECT/database_url" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text)

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

mkdir -p /opt/app

cat > /opt/app/.env <<EOF
DATABASE_URL=$DATABASE_URL
ECR_REGISTRY=$ECR_REGISTRY
NEXT_PUBLIC_API_URL=http://$PUBLIC_IP:8080
EOF

cat > /opt/app/docker-compose.yml <<EOF
services:
  api:
    image: $ECR_REGISTRY/pet-project-api:latest
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: $DATABASE_URL
      NODE_ENV: production
    restart: unless-stopped

  web:
    image: $ECR_REGISTRY/pet-project-web:latest
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://$PUBLIC_IP:8080
      NODE_ENV: production
    restart: unless-stopped
EOF

cd /opt/app
docker compose up -d
