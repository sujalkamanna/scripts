#!/bin/bash

set -e

echo "🚀 Starting Monitoring Server Setup..."

PROM_VERSION="3.2.1"
INSTALL_DIR="/opt"
PROM_DIR="prometheus-$PROM_VERSION.linux-amd64"

cd $INSTALL_DIR

echo "📦 Downloading Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/${PROM_DIR}.tar.gz

echo "📂 Extracting..."
tar -xvf ${PROM_DIR}.tar.gz

cd $PROM_DIR

echo "📁 Setting up binaries..."
cp prometheus promtool /usr/local/bin/

echo "📁 Creating directories..."
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

echo "⚙️ Creating Prometheus config..."
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['3.108.66.47:9100']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]

    static_configs:
      - targets:
        - http://3.108.66.47

    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target

      - source_labels: [__param_target]
        target_label: instance

      - target_label: __address__
        replacement: 3.108.66.47:9115
EOF

echo "⚙️ Creating systemd service..."
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "▶️ Starting Prometheus..."
systemctl enable prometheus
systemctl start prometheus

echo "📊 Installing Grafana..."
apt-get update -y
apt-get install -y grafana

echo "▶️ Starting Grafana..."
systemctl enable grafana-server
systemctl start grafana-server

echo "✅ Monitoring Server Setup Complete!"
echo "👉 Access Grafana: http://<YOUR_PUBLIC_IP>:3000"
echo "👉 Prometheus: http://<YOUR_PUBLIC_IP>:9090"