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
apt update && apt upgrade

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

# Restart SSH service
print_message "Restarting SSH service"
systemctl restart ssh

# Ensure .ssh directory exists
print_message "Creating .ssh directory"
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add SSH public keys to authorized_keys
print_message "Adding SSH public keys to authorized_keys"
cat << 'EOF' >> /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHDV/GXK5SNvVj954rQmYx4f5oicCXWdo0aw1ElkYsR rchoudhury63@gmail.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpDBlyev/RfBkOe/AuuX9rW6xW+cgFQq6F/Bp4UaCYl debatashaktiranjan@gmail.com
EOF

# Ensure correct permissions on authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Create the user named ubuntu
print_message "Creating user 'ubuntu'"
useradd -m -s /bin/bash ubuntu

# Add the user to the sudo group
print_message "Adding 'ubuntu' to the sudo group"
usermod -aG sudo ubuntu

# Disable password login for the 'ubuntu' user
print_message "Disabling password login for 'ubuntu'"
passwd -d ubuntu  # Removes any existing password

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

