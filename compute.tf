provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "openclaw_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = aws_key_pair.demo_key.key_name
  vpc_security_group_ids      = [aws_security_group.openclaw_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.openclaw_profile.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  tags = {
    Name = "OpenClawServer"
  }
}

# Generate SSH key
resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = tls_private_key.demo.public_key_openssh
}

resource "aws_iam_instance_profile" "openclaw_profile" {
  name = "openclaw-instance-profile"
  role = aws_iam_role.openclaw_instance_role.name
}

resource "aws_iam_role_policy_attachment" "openclaw_ssm" {
  role       = aws_iam_role.openclaw_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "openclaw_instance_role" {
  name = "openclaw-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}