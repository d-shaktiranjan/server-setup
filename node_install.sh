#!/bin/bash

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
sudo apt update
sudo apt install -y curl software-properties-common

# Add NodeSource repository for the latest LTS version of Node.js
echo "Adding NodeSource repository for Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install Node.js
echo "Installing Node.js..."
sudo apt install -y nodejs

# Verify installation
echo "Verifying Node.js and npm versions..."
node -v
npm -v

echo "Node.js LTS installation completed!"
