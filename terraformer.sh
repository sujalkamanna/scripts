#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt update -y

echo "Installing dependencies (curl, jq)..."
sudo apt install -y curl jq

echo "Fetching latest Terraformer version from GitHub..."
LATEST_TAG=$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | jq -r '.tag_name')

echo "Latest Terraformer release tag: $LATEST_TAG"

echo "Downloading Terraformer binary for Linux AMD64..."
curl -LO "https://github.com/GoogleCloudPlatform/terraformer/releases/download/${LATEST_TAG}/terraformer-all-linux-amd64"

echo "Making Terraformer executable..."
chmod +x terraformer-all-linux-amd64

echo "Moving Terraformer to /usr/local/bin..."
sudo mv terraformer-all-linux-amd64 /usr/local/bin/terraformer

echo "Sleeping for 2 seconds..."
sleep 2

echo "Installed Terraformer version:"
terraformer --version

echo "Terraformer installation completed successfully!"
