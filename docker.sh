#!/bin/bash
# This script downloads and installs Docker on a Linux system
# Can be run as a normal user; sudo is used for privileged commands

set -e  # Exit immediately if a command fails

# Download Docker install script
echo "Downloading Docker install script..."
curl -fsSL https://get.docker.com -o get-docker.sh

# Preview what will be installed (dry-run)
echo "Previewing Docker installation (dry-run)..."
sudo sh ./get-docker.sh --dry-run

sleep 3

# Install Docker
echo "Installing Docker..."
sudo sh ./get-docker.sh

# Pause before verification
echo "Checking Docker version..."

# Verify Docker installation
echo "Checking Docker version..."
docker --version

echo "Docker installation completed successfully!"

# Usage instructions:
# To run this script:
# Run it: ./docker.sh
# OR
# Run directly with sh: sh docker.sh
