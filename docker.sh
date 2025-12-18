#!/bin/bash
# This script downloads and installs Docker on a Linux system

# Exit immediately if a command exits with a non-zero status
set -e

# Download Docker install script
echo "Downloading Docker install script..."
curl -fsSL https://get.docker.com -o get-docker.sh

# Preview what will be installed
echo "Previewing Docker installation (dry-run)..."
sudo sh ./get-docker.sh --dry-run

echo "Installing Docker..."
sleep 3

sudo sh ./get-docker.sh

echo "Checking Docker version..."
sleep 2

# Verify Docker installation
echo "Checking Docker version..."
docker --version

echo "Docker installation completed successfully!"

#to run this file type or execute command = sh docker.sh
or 
./docker.sh
