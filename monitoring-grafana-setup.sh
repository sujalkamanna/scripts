#!/bin/bash

set -e

echo "🚀 Starting Grafana Installation..."

# -----------------------------
# Install dependencies
# -----------------------------
echo "📦 Installing dependencies..."
apt-get update -y
apt-get install -y apt-transport-https software-properties-common wget gnupg

# -----------------------------
# Add Grafana GPG key
# -----------------------------
echo "🔐 Adding Grafana GPG key..."
mkdir -p /etc/apt/keyrings

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

# -----------------------------
# Add Grafana repository
# -----------------------------
echo "📁 Adding Grafana repository..."
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    | tee /etc/apt/sources.list.d/grafana.list

# -----------------------------
# Install Grafana
# -----------------------------
echo "📦 Installing Grafana..."
apt-get update -y
apt-get install -y grafana

# -----------------------------
# Start Grafana service
# -----------------------------
echo "🚀 Starting Grafana service..."
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

# -----------------------------
# Verify service
# -----------------------------
echo "🔍 Checking Grafana status..."
systemctl status grafana-server --no-pager

# -----------------------------
# Add Prometheus datasource automatically
# -----------------------------
echo "⚙️ Configuring Prometheus datasource..."

cat <<EOF > /etc/grafana/provisioning/datasources/prometheus.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

systemctl restart grafana-server

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
echo "📊 Prometheus datasource already configured!"