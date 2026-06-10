#!/bin/bash

set -e

echo "🚀 Starting Grafana Installation..."

# -----------------------------
# Install dependencies
# -----------------------------
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget gnupg

# -----------------------------
# Add Grafana GPG key
# -----------------------------
echo "🔐 Adding Grafana GPG key..."
sudo mkdir -p /etc/apt/keyrings

wget -q -O - https://apt.grafana.com/gpg.key | \
sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/grafana.gpg

# -----------------------------
# Add Grafana repository
# -----------------------------
echo "📁 Adding Grafana repository..."
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list

# -----------------------------
# Install Grafana
# -----------------------------
echo "📦 Installing Grafana..."
sudo apt-get update -y
sudo apt-get install -y grafana

# -----------------------------
# Enable + start Grafana
# -----------------------------
echo "🚀 Starting Grafana service..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# -----------------------------
# Wait for Grafana to start
# -----------------------------
sleep 5

# -----------------------------
# Configure Prometheus datasource
# -----------------------------
echo "⚙️ Configuring Prometheus datasource..."

sudo mkdir -p /etc/grafana/provisioning/datasources

cat <<EOF | sudo tee /etc/grafana/provisioning/datasources/prometheus.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

# -----------------------------
# Restart Grafana to apply config
# -----------------------------
sudo systemctl restart grafana-server

# -----------------------------
# Verify
# -----------------------------
echo "🔍 Checking Grafana status..."
sudo systemctl status grafana-server --no-pager

# -----------------------------
# Final Output
# -----------------------------
echo "✅ Grafana Setup Complete!"
echo ""
echo "🌐 Access Grafana:"
echo "http://<YOUR_PUBLIC_IP>:3000"
echo ""
echo "🔑 Default Login:"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "📊 Prometheus datasource auto-configured!"