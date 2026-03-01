resource "aws_security_group" "openclaw_sg" {
  name        = "openclaw-sg"
  description = "Allow outbound HTTPS traffic"
  vpc_id      = data.aws_vpc.default.id

  # Outbound HTTPS for LLM APIs, external tools, Telegram, Discord, etc.
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTP for installing apt packages and Node.js dependencies
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR PUBLIC IP/32"]
  }

  tags = {
    Name = "openclaw-sg"
  }
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}