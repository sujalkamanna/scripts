```bash
#!/bin/bash

#==========================================================
# Step 1: Update and Install prerequisites
#==========================================================
echo "🔧 Updating packages and installing prerequisites..."
sudo apt update
sudo apt install -y curl jq

#==========================================================
# Step 2: Install Docker Compose
#==========================================================
echo "📦 Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#==========================================================
# Step 3: Ensure Docker is running
#==========================================================
echo "🚀 Checking Docker service..."
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl restart docker

#==========================================================
# Step 4: Verify Installation
#==========================================================
echo "✅ Verifying Docker Compose installation..."
docker-compose --version
docker --version
sudo systemctl status docker --no-pager

echo "🎉 Docker Compose installation is complete and Docker is running!"
```
