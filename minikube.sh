#!/bin/bash

set -e

### CONFIGURATION ###
NEW_USER="minikubeuser"
NEW_PASS="minikubeuser"
######################

# Check root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Run as root or sudo"
  exit 1
fi

echo "### Updating system..."
apt update -y

echo "### Installing base dependencies..."
apt install -y curl ca-certificates gnupg lsb-release sudo apt-transport-https

#==========================================================
# DOCKER INSTALL (official repo method - stable)
#==========================================================
echo "### Installing Docker..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

#==========================================================
# USER SETUP
#==========================================================
echo "### Creating user: $NEW_USER"

id "$NEW_USER" &>/dev/null || useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:$NEW_PASS" | chpasswd

usermod -aG sudo "$NEW_USER"
usermod -aG docker "$NEW_USER"

#==========================================================
# MINIKUBE INSTALL
#==========================================================
echo "### Installing Minikube..."

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube /usr/local/bin/minikube
rm -f minikube

#==========================================================
# KUBECTL INSTALL
#==========================================================
echo "### Installing kubectl..."

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256) kubectl" | sha256sum --check

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl kubectl.sha256

#==========================================================
# VERIFY INSTALLATIONS
#==========================================================
echo "### Installed versions:"
docker --version
minikube version
kubectl version --client

#==========================================================
# START MINIKUBE (proper user execution)
#==========================================================
echo "### Starting Minikube..."

sudo -u "$NEW_USER" -H bash -c "
export HOME=/home/$NEW_USER
minikube start --driver=docker
"

#==========================================================
# DONE
#==========================================================
echo ""
echo "### Setup Complete!"
echo "User: $NEW_USER"
echo "Password: $NEW_PASS"
echo ""
echo "Switch user:"
echo "  su - $NEW_USER"
echo ""
echo "Check cluster:"
echo "  kubectl get nodes"