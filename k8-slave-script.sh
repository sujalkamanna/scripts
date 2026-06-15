#!/bin/bash
set -e

echo "=== Kubernetes Worker Setup ==="
echo
echo "Paste kubeadm join command:"
read -r JOIN_CMD

sudo $JOIN_CMD \
--cri-socket unix:///run/containerd/containerd.sock

echo
echo "=== Worker Successfully Joined ==="