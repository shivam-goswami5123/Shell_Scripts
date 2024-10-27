#!/bin/bash

# Check if sufficient arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <bucket-name> <region> <create|delete>"
    exit 1
fi

# Assign arguments to variables
BUCKET_NAME=$1
REGION=$2
ACTION=$3

# Function to check if AWS CLI is installed, and install if necessary
check_install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Installing..."
        
        # Detect operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # For Linux
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # For macOS
            curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
            sudo installer -pkg AWSCLIV2.pkg -target /
        else
            echo "Unsupported OS. Please install AWS CLI manually."
            exit 1
        fi

        # Verify installation
        if command -v aws &> /dev/null; then
            echo "AWS CLI installed successfully."
        else
            echo "Failed to install AWS CLI. Exiting."
            exit 1
        fi
    else
        echo "AWS CLI is already installed."
    fi
}

# Function to create an S3 bucket
create_bucket() {
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    echo "Bucket '$BUCKET_NAME' created in region '$REGION'."
}

# Function to delete an S3 bucket
delete_bucket() {
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    echo "Bucket '$BUCKET_NAME' deleted from region '$REGION'."
}

# Ensure AWS CLI is installed
check_install_aws_cli

# Perform the specified action
if [ "$ACTION" == "create" ]; then
    create_bucket
elif [ "$ACTION" == "delete" ]; then
    delete_bucket
else
    echo "Invalid action. Use 'create' or 'delete'."
    exit 1
fi
