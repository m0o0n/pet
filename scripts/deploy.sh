#!/bin/bash
set -euo pipefail

INFRA_DIR="apps/infrastructure"
AWS_REGION="eu-central-1"
AWS_PROFILE="pet-project"
SSH_KEY="$HOME/.ssh/pet-project"

echo "Reading infrastructure outputs..."
ECR_API=$(terraform -chdir="$INFRA_DIR" output -raw ecr_api_url)
ECR_WEB=$(terraform -chdir="$INFRA_DIR" output -raw ecr_web_url)
EC2_IP=$(terraform -chdir="$INFRA_DIR" output -raw ec2_public_ip)
ECR_REGISTRY=$(echo "$ECR_API" | cut -d'/' -f1)

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" --profile "$AWS_PROFILE" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "Building and pushing API image..."
docker build -f apps/api/Dockerfile -t "$ECR_API:latest" .
docker push "$ECR_API:latest"

echo "Building and pushing Web image..."
docker build -f apps/web/Dockerfile \
  --build-arg NEXT_PUBLIC_API_URL="http://$EC2_IP:8080" \
  -t "$ECR_WEB:latest" \
  .
docker push "$ECR_WEB:latest"

echo "Deploying to EC2..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$EC2_IP" \
  "sudo mkdir -p /opt/app && sudo chown ubuntu:ubuntu /opt/app"

scp -i "$SSH_KEY" -o StrictHostKeyChecking=no \
  docker-compose.prod.yml ubuntu@"$EC2_IP":/opt/app/docker-compose.yml

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$EC2_IP" \
  "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY \
   && cd /opt/app && docker compose pull && docker compose up -d"

echo "Done. App is available at http://$EC2_IP:3000"
