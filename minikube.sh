#!/bin/bash
set -e && \
sudo apt update -y && sudo apt upgrade -y && \
sudo apt install -y curl wget ca-certificates gnupg lsb-release && \
curl -fsSL https://get.docker.com | sudo sh && \
sudo systemctl enable docker && sudo systemctl start docker && \
sudo usermod -aG docker $USER && \
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64 && \
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt) && \
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" && \
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check && \
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
rm kubectl kubectl.sha256 && \
docker --version && minikube version && kubectl version --client && \
echo "Done. Run: newgrp docker && minikube start --driver=docker"
