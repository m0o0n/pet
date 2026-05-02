#!/bin/bash
set -euo pipefail

AWS_REGION="${aws_region}"
PROJECT="${project}"
GITHUB_CLIENT_ID="${woodpecker_github_client_id}"
WOODPECKER_ADMIN="${woodpecker_admin}"

# Install Docker
apt-get update -y
apt-get install -y ca-certificates curl gnupg awscli
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
usermod -aG docker ubuntu

# Fetch secrets from SSM
GITHUB_SECRET=$(aws ssm get-parameter \
  --region "$AWS_REGION" \
  --name "/$PROJECT/woodpecker_github_secret" \
  --with-decryption --query 'Parameter.Value' --output text)

AGENT_SECRET=$(aws ssm get-parameter \
  --region "$AWS_REGION" \
  --name "/$PROJECT/woodpecker_agent_secret" \
  --with-decryption --query 'Parameter.Value' --output text)

CI_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

mkdir -p /opt/woodpecker

cat > /opt/woodpecker/docker-compose.yml <<EOF
services:
  woodpecker-server:
    image: woodpeckerci/woodpecker-server:latest
    ports:
      - "8000:8000"
    environment:
      WOODPECKER_OPEN: "false"
      WOODPECKER_HOST: "http://$CI_IP:8000"
      WOODPECKER_GITHUB: "true"
      WOODPECKER_GITHUB_CLIENT: "$GITHUB_CLIENT_ID"
      WOODPECKER_GITHUB_SECRET: "$GITHUB_SECRET"
      WOODPECKER_AGENT_SECRET: "$AGENT_SECRET"
      WOODPECKER_ADMIN: "$WOODPECKER_ADMIN"
    volumes:
      - woodpecker-data:/var/lib/woodpecker/
    restart: unless-stopped

  woodpecker-agent:
    image: woodpeckerci/woodpecker-agent:latest
    environment:
      WOODPECKER_SERVER: "woodpecker-server:9000"
      WOODPECKER_AGENT_SECRET: "$AGENT_SECRET"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - woodpecker-server
    restart: unless-stopped

volumes:
  woodpecker-data:
EOF

cd /opt/woodpecker
docker compose up -d
