#!/bin/bash

set -e

# Download Docker installation script
echo "📥 Downloading Docker installation script..."
curl -fsSL https://get.docker.com -o get-docker.sh

# Preview installation steps (Dry Run)
echo "🔍 Previewing Docker installation..."
sudo sh ./get-docker.sh --dry-run

# Install Docker
echo "🐳 Installing Docker..."
sudo sh ./get-docker.sh

# Enable and start Docker
echo "🚀 Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
echo "🔍 Verifying Docker installation..."
docker --version

echo "✅ Docker installed successfully!"

echo ""
echo "✅ Docker installed successfully!"