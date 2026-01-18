#!/bin/bash
set -e

echo "=== 🚀 Running MASTER setup ==="

# 1. Initialize Kubernetes master
sudo kubeadm init \
--pod-network-cidr=10.244.0.0/16 \
--cri-socket=unix:///run/containerd/containerd.sock

# 2. Configure kubectl for current user
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 3. Deploy Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "=== ✔ MASTER setup complete ==="

# 4. Print join command for workers
echo "=== 🔑 Save this command to join worker nodes ==="
kubeadm token create --print-join-command
