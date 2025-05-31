# AWS EC2 Launch Script (Bash)

This project contains a Bash script that automates the process of launching an EC2 instance on AWS using the AWS CLI.

## Features

- Checks if a security group exists (creates it if it doesn't)
- Adds basic inbound rules for SSH (port 22) and HTTP (port 80)
- Launches a new EC2 instance with specified AMI, instance type, and key pair
- Tags the instance with a custom name
- Displays basic information about the launched instance

## Prerequisites

Make sure you have the following installed and set up:

- AWS CLI configured with your credentials (`aws configure`)
- A valid EC2 key pair created in your AWS region
- Bash environment (Linux, macOS, or WSL/Git Bash on Windows)

## Configuration

Before running the script, set your configuration values at the top of the script:

```bash
REGION="us-east-1"
AMI_ID="ami-0c02fb55956c7d316"  # Amazon Linux 2 (Free Tier)
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-pair-name"
SECURITY_GROUP_NAME="your-security-group"
INSTANCE_NAME="your-instance-name"
