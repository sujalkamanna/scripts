# copy to download file directly
# wget https://raw.githubusercontent.com/sujalkamanna/scripts/main/minikube.sh

#!/bin/bash
set -e

### CONFIGURATION - EDIT IF NEEDED ###
NEW_USER="minikubeuser"
NEW_PASS="minikubeuser"
#######################################

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

echo "### Updating system packages..."
apt update -y

echo "### Installing required tools..."
apt install -y curl ca-certificates gnupg lsb-release sudo

echo "### Installing Docker (latest stable)..."
curl -fsSL https://get.docker.com | sh
systemctl enable --now docker

echo "### Creating new user: $NEW_USER"
useradd -m -s /bin/bash "$NEW_USER" || true
echo "$NEW_USER:$NEW_PASS" | chpasswd

echo "### Adding $NEW_USER to sudo & docker group..."
usermod -aG sudo "$NEW_USER"
usermod -aG docker "$NEW_USER"

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
echo "### Starting Minikube as $NEW_USER..."
sudo -H -u "$NEW_USER" bash << EOF
# ensure docker group refresh
newgrp docker << EEND
echo "Running minikube start..."
minikube start --driver=docker
EEND
EOF

echo ""
echo "### Setup complete!"
echo "User:     $NEW_USER"
echo "Password: $NEW_PASS"
echo ""
echo "To use kubectl, switch to the new user:"
echo "   su - $NEW_USER"
echo "Then try:"
echo "   kubectl get nodes"
echo ""
echo "Done!"
