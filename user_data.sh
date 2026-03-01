#!/bin/bash
set -e

# Update system packages
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y curl git build-essential

# Install Node.js LTS (v22) — required for OpenClaw 2026.2.26+
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Install OpenClaw
npm install -g openclaw@latest

# Log completion
echo "User data script completed successfully at $(date)" >> /var/log/openclaw-setup.log
