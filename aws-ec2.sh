#Check if AWS CLI is configured
aws configure list

#Configure your credentials
aws configure

#Run this to test the credentials
aws sts get-caller-identity

#!/bin/bash

# -------- Configuration --------
REGION="us-east-1"
AMI_ID="ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI (Free Tier eligible)
INSTANCE_TYPE="t2.micro"
KEY_NAME="May-Key-Pair"         # Must already exist in your AWS account
SECURITY_GROUP_NAME="AziSG"
INSTANCE_NAME="MyFirstEC2"

# -------- Step 1: Check or Create Security Group --------
echo "Checking for existing security group: $SECURITY_GROUP_NAME"
SG_ID=$(aws ec2 describe-security-groups \
    --region $REGION \
    --group-names "$SECURITY_GROUP_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text 2>/dev/null)

if [ "$SG_ID" == "None" ] || [ -z "$SG_ID" ]; then
    echo "Security group not found. Creating new one..."
    VPC_ID=$(aws ec2 describe-vpcs \
        --region $REGION \
        --query "Vpcs[0].VpcId" \
        --output text)

    SG_ID=$(aws ec2 create-security-group \
        --region $REGION \
        --group-name "$SECURITY_GROUP_NAME" \
        --description "My basic security group" \
        --vpc-id "$VPC_ID" \
        --query 'GroupId' \
        --output text)

    echo "Created security group with ID: $SG_ID"

    # Add inbound rules
    echo "Adding inbound rules (SSH & HTTP)..."
    aws ec2 authorize-security-group-ingress \
        --region $REGION \
        --group-id "$SG_ID" \
        --protocol tcp --port 22 --cidr 0.0.0.0/0

    aws ec2 authorize-security-group-ingress \
        --region $REGION \
        --group-id "$SG_ID" \
        --protocol tcp --port 80 --cidr 0.0.0.0/0

    echo "Ingress rules added"
else
    echo "Security group '$SECURITY_GROUP_NAME' already exists. Reusing: $SG_ID"
fi

# -------- Step 2: Launch EC2 Instance --------
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --region $REGION \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --count 1 \
    --query "Instances[0].InstanceId" \
    --output text)

echo "Instance launched with ID: $INSTANCE_ID"

# -------- Step 3: Tag Instance --------
echo "Tagging instance as '$INSTANCE_NAME'..."
aws ec2 create-tags \
    --region $REGION \
    --resources "$INSTANCE_ID" \
    --tags Key=Name,Value="$INSTANCE_NAME"

# -------- Step 4: Show Instance Info --------
echo "Waiting for instance to initialize..."
sleep 10

aws ec2 describe-instances \
    --region $REGION \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[].Instances[].{Instance:InstanceId,PublicDNS:PublicDnsName,State:State.Name}" \
    --output table
