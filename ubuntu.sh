#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Change timezone to India
print_message "Changing timezone to India (Asia/Kolkata)"
timedatectl set-timezone Asia/Kolkata

# Update packages
print_message "Updating packages"
apt update && apt upgrade -y

# Install Nginx
print_message "Installing Nginx"
apt install -y nginx

# Start and enable Nginx
print_message "Starting and enabling Nginx"
systemctl start nginx
systemctl enable nginx

# Configure SSH
print_message "Configuring SSH"
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
print_message "Restarting SSH service"
systemctl restart ssh

# Create the user named ubuntu
print_message "Creating user 'ubuntu'"
useradd -m -s /bin/bash ubuntu

# Add the user to the sudo group
print_message "Adding 'ubuntu' to the sudo group"
usermod -aG sudo ubuntu

# Configure passwordless sudo for all users in sudo group
print_message "Configuring passwordless sudo for sudo group"
sed -i 's/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
# fallback if line doesn't exist
if ! grep -q "^%sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Define the authorized_keys file path
AUTHORIZED_KEYS_FILE="/home/ubuntu/.ssh/authorized_keys"

# Create the .ssh directory if it doesn't exist
SSH_DIR="/home/ubuntu/.ssh"
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chown ubuntu:ubuntu "$SSH_DIR"
fi

# Ensure the authorized_keys file exists and has the correct permissions
touch "$AUTHORIZED_KEYS_FILE"
chmod 600 "$AUTHORIZED_KEYS_FILE"
chown ubuntu:ubuntu "$AUTHORIZED_KEYS_FILE"

# Add SSH public keys to authorized_keys
print_message "Adding SSH public keys to authorized_keys"
cat << 'EOF' >> $AUTHORIZED_KEYS_FILE
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHDV/GXK5SNvVj954rQmYx4f5oicCXWdo0aw1ElkYsR rchoudhury63@gmail.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpDBlyev/RfBkOe/AuuX9rW6xW+cgFQq6F/Bp4UaCYl debatashaktiranjan@gmail.com
EOF

# Prompt user to install Node.js
read -p "Do you want to install Node.js (latest LTS)? [y/n]: " install_node

if [[ $install_node =~ ^[Yy]$ ]]; then
    print_message "Installing Node.js..."
    curl -sSL https://raw.githubusercontent.com/d-shaktiranjan/server-setup/main/node_install.sh | bash
    print_message "Node.js installation completed."
else
    print_message "Node.js installation skipped."
fi

print_message "Setup completed successfully"

