#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y unzip curl git

# Download latest Terraformer release
TERRAFORMER_VERSION="0.17.10"  # Change to latest if needed
echo "Downloading Terraformer version $TERRAFORMER_VERSION..."
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$TERRAFORMER_VERSION/terraformer-all-linux-amd64.zip

echo "Extracting Terraformer..."
unzip terraformer-all-linux-amd64.zip
sudo mv terraformer /usr/local/bin/
rm terraformer-all-linux-amd64.zip

echo "Verifying Terraformer installation..."
terraformer --version

echo "Terraformer installed successfully!"
