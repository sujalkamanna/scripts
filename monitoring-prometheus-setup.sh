#!/bin/bash

set -e

echo "🚀 Starting Monitoring Server Setup..."

# -------------------------
# Variables
# -------------------------
PROM_VERSION="2.54.1"
BLACKBOX_VERSION="0.27.0"
INSTALL_DIR="/opt"

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# -------------------------
# Install dependencies
# -------------------------
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y wget tar gnupg software-properties-common

# -------------------------
# Install Prometheus
# -------------------------
echo "📦 Installing Prometheus..."

PROM_DIR="prometheus-${PROM_VERSION}.linux-amd64"

wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/${PROM_DIR}.tar.gz

tar -xvf ${PROM_DIR}.tar.gz
cd ${PROM_DIR}

sudo cp prometheus promtool /usr/local/bin/

sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# -------------------------
# Prometheus config
# -------------------------
echo "⚙️ Creating Prometheus config..."

cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter_app'
    static_configs:
      - targets: ['APP_SERVER_PRIVATE_IP:9100']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]

    static_configs:
      - targets:
        - http://YOUR_APPLICATION_URL_OR_IP

    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target

      - source_labels: [__param_target]
        target_label: instance

      - target_label: __address__
        replacement: localhost:9115
EOF

# -------------------------
# Prometheus systemd service
# -------------------------
echo "⚙️ Creating Prometheus service..."

cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# -------------------------
# Start Prometheus
# -------------------------
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# -------------------------
# Install Blackbox Exporter
# -------------------------
echo "📦 Installing Blackbox Exporter..."

cd $INSTALL_DIR

BB_DIR="blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64"

wget https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/${BB_DIR}.tar.gz

tar -xvf ${BB_DIR}.tar.gz
cd ${BB_DIR}

sudo cp blackbox_exporter /usr/local/bin/

sudo mkdir -p /etc/blackbox

cat <<EOF | sudo tee /etc/blackbox/blackbox.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
EOF

# -------------------------
# Blackbox systemd service
# -------------------------
cat <<EOF | sudo tee /etc/systemd/system/blackbox.service
[Unit]
Description=Blackbox Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=0.0.0.0:9115
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable blackbox
sudo systemctl start blackbox

# -------------------------
# Install Grafana
# -------------------------
echo "📊 Installing Grafana..."

sudo mkdir -p /etc/apt/keyrings

wget -q -O - https://apt.grafana.com/gpg.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update -y
sudo apt-get install -y grafana

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# -------------------------
# Final output
# -------------------------
echo "✅ Monitoring Server Setup Complete!"
echo "👉 Grafana: http://<PUBLIC_IP>:3000"
echo "👉 Prometheus: http://<PUBLIC_IP>:9090"
echo "👉 Blackbox: http://<PUBLIC_IP>:9115"