#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
SCRIPT_URL="https://raw.githubusercontent.com/d-shaktiranjan/server-setup/main/ubuntu.sh"
SCRIPT_NAME="ubuntu.sh"
LOG_FILE="setup.log"

# Download the script
echo "Downloading script from $SCRIPT_URL..."
curl -O "$SCRIPT_URL" || { echo "Failed to download script"; exit 1; }

# Make the script executable
echo "Making $SCRIPT_NAME executable..."
chmod +x "$SCRIPT_NAME" || { echo "Failed to make script executable"; exit 1; }

# Run the script and log output
echo "Executing $SCRIPT_NAME..."
{
    echo "Start time: $(date)"
    if [[ -n "$INSTALL_NODE" ]]; then
        echo "INSTALL_NODE is set to $INSTALL_NODE"
    fi
    ./"$SCRIPT_NAME"
    echo "End time: $(date)"
} | tee "$LOG_FILE"

# Optional: Clean up the script file after execution
echo "Cleaning up..."
rm "$SCRIPT_NAME"

echo "Script execution completed. Logs are available in $LOG_FILE"
