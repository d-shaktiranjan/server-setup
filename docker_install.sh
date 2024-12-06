#!/bin/bash

# Function to print error messages
error() {
    echo "[ERROR] $1" >&2
}

# Function to print info messages
info() {
    echo "[INFO] $1"
}

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root or with sudo"
    exit 1
fi

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    error "This script is designed for Ubuntu only"
    exit 1
fi

info "Starting Docker installation process..."

# Remove existing Docker installations
info "Removing existing Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg >/dev/null 2>&1
done

# Update package index
info "Updating package index..."
if ! sudo apt-get update; then
    error "Failed to update package index"
    exit 1
fi

# Install prerequisites
info "Installing required packages..."
if ! sudo apt-get install -y ca-certificates curl; then
    error "Failed to install prerequisites"
    exit 1
fi

# Set up Docker's GPG key
info "Setting up Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
if ! sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; then
    error "Failed to download Docker's GPG key"
    exit 1
fi
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
info "Updating package index with new repository..."
if ! sudo apt-get update; then
    error "Failed to update package index after adding Docker repository"
    exit 1
fi

# Install Docker packages
info "Installing Docker packages..."
if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    error "Failed to install Docker packages"
    exit 1
fi

# Create docker group if it doesn't exist
info "Setting up Docker group..."
sudo groupadd docker 2>/dev/null || true

# Add user to docker group
info "Adding current user to Docker group..."
if ! sudo usermod -aG docker $USER; then
    error "Failed to add user to Docker group"
    exit 1
fi

# Enable Docker services
info "Enabling Docker services..."
if ! sudo systemctl enable docker.service; then
    error "Failed to enable docker.service"
    exit 1
fi

if ! sudo systemctl enable containerd.service; then
    error "Failed to enable containerd.service"
    exit 1
fi

# Final success message
info "Docker installation completed successfully!"
info "IMPORTANT: Please log out and log back in for group changes to take effect"
info "You may also need to restart your system for all changes to take effect"

# Check if Docker daemon is running
if sudo systemctl is-active --quiet docker; then
    info "Docker service is running"
else
    info "Docker service is not running. Starting it now..."
    sudo systemctl start docker || error "Failed to start Docker service"
fi

# Verify Docker installation
info "Verifying Docker installation..."
if docker --version >/dev/null 2>&1; then
    info "Docker was installed successfully!"
    docker --version
else
    error "Docker installation verification failed. Please restart your system and try again."
fi
