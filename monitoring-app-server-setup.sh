#!/bin/bash

set -e

echo "🚀 Starting Application Server Setup..."

INSTALL_DIR="/opt"

# -------------------------
# Node Exporter
# -------------------------
NODE_VERSION="1.8.2"
NODE_DIR="node_exporter-${NODE_VERSION}.linux-amd64"

cd $INSTALL_DIR

echo "📦 Downloading Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/${NODE_DIR}.tar.gz

echo "📂 Extracting..."
tar -xvf ${NODE_DIR}.tar.gz

cd $NODE_DIR

echo "▶️ Starting Node Exporter..."
nohup ./node_exporter --web.listen-address="0.0.0.0:9100" > /var/log/node_exporter.log 2>&1 &

# -------------------------
# Blackbox Exporter
# -------------------------
BLACKBOX_VERSION="0.27.0"
BLACKBOX_DIR="blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64"

cd $INSTALL_DIR

echo "📦 Downloading Blackbox Exporter..."
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/${BLACKBOX_DIR}.tar.gz

echo "📂 Extracting..."
tar -xvf ${BLACKBOX_DIR}.tar.gz

cd $BLACKBOX_DIR

echo "▶️ Starting Blackbox Exporter..."
nohup ./blackbox_exporter --web.listen-address="0.0.0.0:9115" > /var/log/blackbox_exporter.log 2>&1 &

echo "✅ Application Server Setup Complete!"

echo "🔍 Verifying services..."
ss -tulnp | grep 9100 || true
ss -tulnp | grep 9115 || true

echo "🌐 Test locally:"
echo "curl http://localhost:9100/metrics"
echo "curl http://localhost:9115/probe?target=google.com&module=http_2xx"