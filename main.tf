locals {
  common_tags = {
    Environment = var.environment
    Project     = "OpenClaw"
    ManagedBy   = "Terraform"
  }

  service_name = "openclaw"
}
