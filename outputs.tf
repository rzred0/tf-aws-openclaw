output "instance_id" {
  description = "OpenClaw instance ID for SSM access"
  value       = aws_instance.openclaw_server.id
}

# Output private key for SSH
output "private_key_pem" {
  value     = tls_private_key.demo.private_key_pem
  sensitive = true
}

output "instance_public_ip" {
  description = "OpenClaw instance public IP (for reference/monitoring only)"
  value       = aws_instance.openclaw_server.public_ip
}

output "ssm_start_session_command" {
  description = "Command to connect to the instance via AWS Systems Manager Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.openclaw_server.id}"
}

output "openclaw_onboard_instruction" {
  description = "Instructions for setting up OpenClaw after connecting"
  value       = <<-EOT
    After connecting via SSM, run the following commands:
    
    npm install -g openclaw@latest
    openclaw onboard --install-daemon
    
    Then configure your Telegram bot or Discord bot when prompted.
  EOT
}