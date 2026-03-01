variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type for OpenClaw server"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}


