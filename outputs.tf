output "private_key_pem" {
  description = "Private key for SSH access"
  value     = tls_private_key.demo.private_key_pem
  sensitive = true
}

output "instance_public_ip" {
  description = "OpenClaw instance public IP for SSH access"
  value       = aws_instance.openclaw_server.public_ip
}

output "openclaw_onboard_instruction" {
  description = "Instructions for setting up OpenClaw after connecting"
  value       = <<-EOT
    After connecting via SSH, run the following command:
    openclaw onboard --install-daemon
    EOT
}