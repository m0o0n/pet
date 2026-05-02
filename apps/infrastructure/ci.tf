resource "aws_security_group" "ci" {
  name        = "${var.project}-ci-sg"
  description = "Woodpecker CI: SSH from whitelisted IPs, UI open for GitHub webhooks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
    description = "SSH from whitelisted IPs"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Woodpecker UI and GitHub webhooks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-ci-sg"
  }
}

resource "aws_instance" "ci" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.ci.name
  vpc_security_group_ids = [aws_security_group.ci.id]

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/ci_user_data.sh", {
    aws_region                = var.aws_region
    project                   = var.project
    woodpecker_github_client_id = "Ov23lif3oheyCvNup0EA"
    woodpecker_admin          = "m0o0n"
  })

  tags = {
    Name = "${var.project}-ci"
  }
}
