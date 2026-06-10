#!/bin/bash

set -e

echo "🚀 Starting Application Server Setup (Node Exporter only)..."

# -------------------------
# Variables
# -------------------------
INSTALL_DIR="/opt"
NODE_VERSION="1.8.2"
NODE_DIR="node_exporter-${NODE_VERSION}.linux-amd64"
TAR_FILE="${NODE_DIR}.tar.gz"

# -------------------------
# Install dependencies
# -------------------------
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y wget tar

# -------------------------
# Create install directory safely
# -------------------------
echo "📁 Preparing installation directory..."
sudo mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# -------------------------
# Download Node Exporter
# -------------------------
echo "📦 Downloading Node Exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/${TAR_FILE}

# -------------------------
# Extract
# -------------------------
echo "📂 Extracting Node Exporter..."
tar -xvf ${TAR_FILE}

cd $NODE_DIR

# -------------------------
# Stop old instance if running
# (important for reruns)
# -------------------------
echo "🧹 Cleaning old processes if any..."
pkill node_exporter || true

# -------------------------
# Start Node Exporter
# -------------------------
echo "▶️ Starting Node Exporter..."
nohup ./node_exporter --web.listen-address="0.0.0.0:9100" > /var/log/node_exporter.log 2>&1 &

sleep 2

# -------------------------
# Verification
# -------------------------
echo "🔍 Verifying service..."

if ss -tulnp | grep -q 9100; then
    echo "✅ Node Exporter is running on port 9100"
else
    echo "❌ Node Exporter failed to start"
    exit 1
fi

echo "🌐 Test command:"
echo "curl http://localhost:9100/metrics"

echo "🎯 Application Server Setup Completed Successfully!"