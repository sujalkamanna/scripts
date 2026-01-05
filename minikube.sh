#!/bin/bash
set -e

# --- CONFIGURATION (edit as needed) ---
NEW_USER="minikubeuser"
NEW_PASS="Minikube@123"
# --------------------------------------

echo "### Updating system packages..."
apt update -y && apt upgrade -y

echo "### Installing required tools..."
apt install -y curl ca-certificates gnupg lsb-release sudo

echo "### Installing Docker (latest stable)..."
curl -fsSL https://get.docker.com | sh
systemctl enable --now docker

echo "### Creating new non-root user: $NEW_USER"
# Create the user and set password
useradd -m -s /bin/bash $NEW_USER
echo "$NEW_USER:$NEW_PASS" | chpasswd

echo "### Adding $NEW_USER to sudoers and docker group..."
usermod -aG sudo $NEW_USER
usermod -aG docker $NEW_USER

echo "### Installing Minikube (latest)..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "### Installing kubectl (latest stable)..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

echo "### Versions installed:"
docker --version
minikube version
kubectl version --client

echo ""
echo "### NEXT STEPS (IMPORTANT):"
echo "1) Log in as the new user:"
echo "     su - $NEW_USER"
echo "2) Start Minikube as that user (not root):"
echo "     minikube start --driver=docker"
echo ""
echo "User credentials:"
echo "   Username: $NEW_USER"
echo "   Password: $NEW_PASS"
