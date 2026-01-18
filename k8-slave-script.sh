#!/bin/bash
set -e

echo "=== 🚀 Running WORKER setup ==="
echo "Paste your kubeadm join command from the master below:"
read JOIN_CMD

sudo $JOIN_CMD --cri-socket unix:///run/containerd/containerd.sock

echo "=== ✔ Worker successfully joined the cluster ==="
