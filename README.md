# AWS OpenClaw Infrastructure as Code

This repository contains Terraform configuration to deploy OpenClaw on AWS EC2 with automatic SSH key generation and AWS Systems Manager Session Manager access.

## Project Overview

OpenClaw is deployed on an Ubuntu 24.04 EC2 instance with automatic initialization including:
- Node.js 22 installation
- OpenClaw CLI installation
- Auto-generated SSH key pair for emergency access

## Prerequisites

### AWS Account & CLI Setup
1. **Create an AWS Account** - Sign up for a free tier account at https://aws.amazon.com/free/
2. **Configure AWS Credentials** - Run `aws configure` and provide your Access Key ID and Secret Access Key
3. **Verify Permissions** - Ensure your IAM user has permissions for EC2, VPC, IAM, and Systems Manager

### Local Tools
1. **Install Terraform** - Download from https://www.terraform.io/downloads (version >= 1.5.0)
2. **Install AWS CLI** - Follow instructions at https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
2. **Install curl** - For getting your public IP address (verify with `curl -4 ifconfig.me`)

### Free Tier Eligibility
This configuration is designed to qualify for AWS free tier:
- **EC2**: t3.small by default
- **Storage**: 30GB EBS volume (included in 30GB free tier monthly allowance)
- **Data Transfer**: Minimal - should stay within free tier limits
- **VPC**: Uses default VPC (free tier eligible)

**Note**: To stay within free tier, modify [variables.tf](variables.tf) and change `instance_type` default from `t3.small` to `t2.micro`.

## Deployment Steps

### Step 1: Clone or Navigate to Repository
```bash
cd /path/to/tf-aws-openclaw
```

### Step 2: Update Security Group IP Whitelist (CRITICAL)
The security group currently has a hardcoded SSH ingress rule with a specific IP address. **You must replace this with your public IP address.**

1. Get your public IP:
   ```bash
   curl -4 ifconfig.me
   ```

2. Update the IP whitelist in [network.tf](network.tf):
   - Find the line with `cidr_blocks = ["YOUR PUBLIC IP/32"]`
   - Replace `YOUR PUBLIC IP` with your public IP address
   - Keep the `/32` suffix (indicates a single IP address)

Example:
```terraform
cidr_blocks = ["YOUR.IP.ADDRESS/32"]  # Replace with your actual IP
```

### Step 3: Initialize Terraform
```bash
terraform init
```

This downloads the required Terraform providers (AWS and TLS).

### Step 4: Review Configuration (Optional)
```bash
terraform plan
```

### Step 5: Deploy Infrastructure
```bash
terraform apply
```

- Type `yes` when prompted to confirm
- Wait 2-3 minutes for EC2 instance to launch and user data script to complete
- Terraform outputs will display important information needed for access

### Step 6: Save Output Values
After deployment completes, Terraform will output:
- `instance_public_ip` - Instance's public IP address (for optional SSH access)
- `private_key_pem` - Your auto-generated SSH private key (see below)

Save the private key output in a safe location:
```bash
terraform output private_key_pem > ~/.ssh/openclaw_key.pem
chmod 400 ~/.ssh/openclaw_key.pem
```

## Accessing Your OpenClaw Instance

### SSH via Private Key
After extracting the private key (see above):

```bash
ssh -i ~/.ssh/openclaw_key.pem ubuntu@<public-ip>
```

Where `<public-ip>` is the output from `terraform output instance_public_ip`

## Post-Deployment: OpenClaw Setup

Once connected to the instance, complete OpenClaw configuration:

```bash
openclaw onboard --install-daemon
```

OpenClaw will then run as a daemon and auto-start on reboot.

## Cleanup & Cost Management

To destroy all resources and avoid charges (especially important for non-free-tier instances):

```bash
terraform destroy
```

## Files Overview

| File | Purpose |
|------|---------|
| [main.tf](main.tf) | Common tags and service naming |
| [providers.tf](providers.tf) | Terraform provider version requirements |
| [compute.tf](compute.tf) | EC2 instance, SSH key pair, IAM role configuration |
| [network.tf](network.tf) | Security group with ingress/egress rules |
| [variables.tf](variables.tf) | Input variables with defaults |
| [outputs.tf](outputs.tf) | Output values displayed after deployment |
| [user_data.sh](user_data.sh) | Automated setup script run on instance launch |

## Security Considerations

1. **SSH Whitelist**: Ensure you've updated the security group with your actual IP address (see Step 2)
2. **Private Key**: The auto-generated private key is marked as sensitive in outputs. Store securely and never commit to version control
3. **Outbound Access**: Security group allows outbound HTTPS/HTTP for LLM APIs and package downloads

## Troubleshooting

### Instance stuck "initializing" after 10 minutes
- SSH into instance and check: `tail -f /var/log/openclaw-setup.log`
- Verify internet connectivity for apt and npm downloads

### Cannot connect via SSH
- Confirm you updated the security group IP in [network.tf](network.tf)
- Verify your current IP hasn't changed: `curl -4 ifconfig.me`

### OpenClaw won't start
- Check installation: `npm list -g openclaw`
- Verify user_data.sh completed: `cat /var/log/openclaw-setup.log`
- Check Node.js version: `node --version` (should be v22.x+)

### Terraform apply fails
- Confirm AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for EC2, VPC, IAM, and Systems Manager
- Verify AWS region is available and you haven't exceeded resource limits

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [OpenClaw Documentation](https://github.com/openclaw/openclaw)

## License

This Terraform configuration is provided as-is for deploying OpenClaw on AWS.
