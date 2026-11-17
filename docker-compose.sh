
#!/bin/bash

set -e

#==========================================================
# Step 1: Update packages and install prerequisites
#==========================================================
echo "🔧 Updating packages and installing prerequisites..."

sudo apt update
sudo apt install -y ca-certificates curl gnupg

#==========================================================
# Step 2: Configure Docker repository
#==========================================================
echo "🐳 Configuring Docker repository..."

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#==========================================================
# Step 3: Install Docker Engine and Compose V2
#==========================================================
echo "📦 Installing Docker Engine and Docker Compose V2..."

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

#==========================================================
# Step 4: Enable and start Docker service
#==========================================================
echo "🚀 Starting Docker service..."

sudo systemctl enable docker
sudo systemctl start docker

#==========================================================
# Step 5: Verify installation
#==========================================================
echo "✅ Verifying Docker installation..."

docker --version
docker compose version

sudo systemctl status docker --no-pager

echo "🎉 Docker Engine and Docker Compose V2 installation completed!"