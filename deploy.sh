#!/usr/bin/env bash

# Exit script on error
set -e

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Define log directory and file
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"  # Create log directory if it doesn't exist
LOG_FILE="$LOG_DIR/deploy.log"

# Check if there is a log file from previous execution 
log "Verifying if there is any previous log file" 
if test -f "$LOG_FILE"; then
    log "Renaming older log files..."
    mv "$LOG_FILE" "$LOG_DIR/deploy_$(date '+%Y-%m-%d_%H-%M-%S').log"
fi

# Redirect all script output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

log "Starting deployment script..."

# Function to clean up old log files, keeping a maximum of 5
cleanup_logs() {
    log "Checking and cleaning old log files..."
    
    # Get all deploy.log files (excluding the current one)
    log_files=($LOG_DIR/deploy_*.log)
    log_count=${#log_files[@]}  # Count how many log files there are

    if [ "$log_count" -gt 3 ]; then
        # Sort the log files by modification time (oldest first)
        oldest_logs=$(ls -t $LOG_DIR/deploy_*.log | tail -n $(($log_count - 3)))
        
        for log in $oldest_logs; do
            log "Deleting old log file: $log"
            rm -f "$log"
        done
    fi
}

# Clean up old logs
cleanup_logs

# Request user to select which Cloud Provider will be used.
### WORKING IN PROGRESS ####
# read -p "What Cloud Provider do you want to use? (oracle, aws) " PROVIDER

# Function to check if required commands exist
check_dependencies() {
    local missing_deps=()
    local dependencies=("terraform" "packer" "ansible" "gcp" "ssh")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log "Error: The following dependencies are missing: ${missing_deps[*]}"
        log "Please install them before proceeding."
        exit 1
    fi
}

# Check dependencies before proceeding
log "Checking required dependencies..."
check_dependencies
log "All dependencies are installed."

# Ask user whether to deploy or destroy resources
read -p "Do you want to deploy or destroy resources? (deploy/destroy): " ACTION

# Prompt the user for required variables
read -p "Enter your OCI Tenancy OCID: " TENANCY_OCID
read -p "Enter your OCI Compartment OCID: " COMPARTMENT_OCID
read -p "Enter your OCI Region (e.g., us-ashburn-1): " REGION
read -p "Enter your SSH Public Key file path: " SSH_PUBLIC_KEY

# Export variables for Terraform
export TF_VAR_tenancy_ocid=$TENANCY_OCID
export TF_VAR_compartment_ocid=$COMPARTMENT_OCID
export TF_VAR_region=$REGION
export TF_VAR_ssh_public_key=$(cat "$SSH_PUBLIC_KEY")

# Function to clean up temporary files
cleanup() {
    log "Cleaning up temporary files..."
    rm -f terraform.tfstate.backup
}
trap cleanup EXIT

if [[ "$ACTION" == "destroy" ]]; then
    log "Destroying all resources..."
    terraform destroy -auto-approve
    log "All resources destroyed successfully!"
    exit 0
fi

# Verify if Terraform is initialized
if [ ! -d ".terraform" ]; then
    log "Initializing Terraform..."
    terraform init --upgrade
else
    log "Terraform is already initialized."
fi

# Validate Terraform configuration
log "Validating Terraform configuration..."
terraform validate

# Run Terraform Plan (Dry-Run) if user wants
read -p "Do you want to run a Terraform plan before applying? (y/n): " RUN_PLAN
if [[ "$RUN_PLAN" == "y" ]]; then
    terraform plan
fi

# Check if the Compute instance already exists
log "Checking for existing Compute instances..."
EXISTING_INSTANCE=$(oci compute instance list --compartment-id "$COMPARTMENT_OCID" --region "$REGION" --query "data[?lifecycle-state=='RUNNING'].id" --raw-output)

if [ -n "$EXISTING_INSTANCE" ]; then
    log "A running Compute instance already exists. Skipping Terraform apply."
else
    log "No running Compute instance found. Applying Terraform..."
    terraform apply -auto-approve
fi

# Retrieve Compute instance public IP from Terraform output
INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "")

if [ -z "$INSTANCE_IP" ]; then
    log "Error: Unable to retrieve instance IP. Ensure Terraform applied successfully."
    exit 1
fi

# Check SSH connectivity before running Ansible
log "Checking SSH connectivity to instance..."
for i in {1..5}; do
    ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP "echo 'SSH Connection Successful'" && break
    log "Retrying SSH connection ($i/5)..."
    sleep 5
done

# Build an OCI custom image with Packer
log "Building an OCI custom image with Packer..."
packer build -var "compartment_id=$COMPARTMENT_OCID" -var "region=$REGION" packer/webserver.json

# Run Ansible Playbook for instance configuration
log "Configuring instance with Ansible..."
ansible-playbook -i "$INSTANCE_IP," --private-key ~/.ssh/id_rsa ansible/playbook.yml

log "Deployment completed successfully!"