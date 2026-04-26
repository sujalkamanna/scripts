#!/bin/bash

set -e

echo "📥 Downloading Docker install script..."
curl -fsSL https://get.docker.com -o get-docker.sh

echo "🔍 Previewing Docker installation (dry-run)..."
sudo sh get-docker.sh --dry-run

sleep 3

echo "🐳 Installing Docker..."
sudo sh get-docker.sh

#==========================================================
# Post-install steps
#==========================================================

echo "🚀 Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group
echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Verify installation
echo "🔍 Docker version:"
docker --version

echo ""
echo "✅ Docker installed successfully!"
echo "⚠️ You may need to log out and log back in to use Docker without sudo."