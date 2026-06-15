#!/bin/bash
set -e

echo "=== Kubernetes Control Plane Setup ==="

sudo kubeadm init \
--pod-network-cidr=10.244.0.0/16 \
--cri-socket=unix:///run/containerd/containerd.sock

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf \
$HOME/.kube/config

sudo chown $(id -u):$(id -g) \
$HOME/.kube/config

echo
echo "Deploying Flannel..."

kubectl apply -f \
https://raw.githubusercontent.com/flannel-io/flannel/v0.27.0/Documentation/kube-flannel.yml

echo
echo "Waiting 30 seconds..."
sleep 30

echo
kubectl get nodes -o wide

echo
kubectl get pods -A

echo
echo "=== Control Plane Ready ==="

echo
echo "===== WORKER JOIN COMMAND ====="
kubeadm token create --print-join-command
echo "================================"