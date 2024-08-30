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

# Install Nginx
print_message "Installing Nginx"
apt update && apt install -y nginx

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

print_message "Setup completed successfully"

