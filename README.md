# AWS Minecraft Server Setup

## Overview
This Terraform configuration provides a deployment solution for a self-healing Minecraft server on AWS. Designed specifically for educational environments like AWS Learning Labs, it handles all infrastructure provisioning and server configuration automatically. The setup is optimized for reliability and security while maintaining simplicity for student users.

## AWS Resources Created
This Terraform configuration will create:
- 1 EC2 instance (t3.small)
- 1 Security Group with rules for:
  - SSH access (port 22) from your IP
  - Minecraft server access (port 25565) from anywhere
  - All outbound traffic
- 1 AWS Key Pair for SSH access
- Associated IAM instance profile permissions

## Key Features
This automated deployment:
1. **Self-healing Server**: Automatically restarts the Minecraft server if it crashes
2. **Learning Lab Compatible**: Works with AWS Learning Lab environments for education
3. **Modern Runtime**: Uses Java 21 (Amazon Corretto) for optimal performance
4. **Secure Defaults**:
   - SSH restricted to your IP only
   - Dedicated system user for Minecraft
   - Proper file permissions

## Technical Implementation
The solution:
1. Provisions all necessary AWS infrastructure
2. Configures a dedicated `minecraft` user with proper permissions
3. Installs and configures Java 21 runtime
4. Downloads the official Minecraft server jar
5. Sets up systemd service for automatic management
6. Implements auto-restart


## Prerequisites

1. **Terraform Installation**:

Follow the link to install the correct version of Terraform for your system

- [Terraform Install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


2. **AWS CLI Installation**:

Follow the link to install the correct version of AWS CLI for your system

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)


3. **AWS Academy Learner Lab Setup**:

You will need to configure your AWS credentials for Terraform:
1. Start your AWS Academy Learner Lab
2. Click on "AWS Details" in the top right corner
3. Create credentials file:

```bash
mkdir -p ~/.aws
vim ~/.aws/credentials
```
4. Place AWS CLI Credentials into the created file and save it

## Getting Started

1. Create a folder for your terraform script
2. Place the main.tf file into the created folder and open it in an editor

### Edditing The Script

- The script works based on the variables provided at the top of the scrip file.
- Ensure to fill out correct information that is accurate to your region and learning lab

```hcl
variable "your_region" {
  default = "us-west-2"  # Change this to match your AWS Academy region
}

variable "your_ami" {
  default = "ami-0418306302097dbff"  # AMI for Amazon Linux in your region
}

variable "iam_instance_profile" {
  default = "LabInstanceProfile"  # Keep this unless your lab uses a different profile name
}

variable "your_ip" {
  default = "128.193.154.254"  # REPLACE with your current public IP
}

variable "your_public_key" {
  default = "ssh-rsa AAAAB3NzaC..."  # REPLACE with your SSH public key
}

variable "mojang_server_url" {
  default = "https://piston-data.mojang.com/..."  # Only change if you need a specific Minecraft version
}
```

- After the change of the variable you are done edditing the script. Save the file and open your terminal

### Running The Code

1. In the terminal nevigate to the folder with your main.tf script
2. Now run the commands to start the terrafom and the minecraft server setup.

```bash
terraform init
terraform plan
terraform apply
```
After running the last command, wait until it is finished and you are done setting up your minecraft server.
In your terminal there will be a public IP of the server that you can use to connect to your game!

## Recources Used
This project incorporates concepts and code snippets from these valuable resources:

1. **Linux Minecraft Server Setup Guide**:
   - [Ubuntu 22.04 Minecraft Server Setup](https://linuxconfig.org/ubuntu-22-04-minecraft-server-setup)
   - Used for server configuration best practices and Java runtime setup

2. **Terraform Minecraft Reference Implementation**:
   - [HarryNash/terraform-minecraft](https://github.com/HarryNash/terraform-minecraft)
   - Provided the foundational Terraform configuration structure







