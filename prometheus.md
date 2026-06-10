# 📄 Prometheus Monitoring Setup on AWS EC2 (Production Guide)

This guide explains a **working AWS monitoring architecture** using:

* 🖥️ **Monitoring Server (Prometheus + Grafana)**
* 🌐 **Application/Web Server (Node Exporter + Blackbox Exporter)**

---

# 🏗️ Architecture Overview

## 🖥️ Monitoring Server

**Role:** Central monitoring system
**Runs:**

* Prometheus (9090)
* Grafana (3000)

---

## 🌐 Application Server (Web Server)

**Role:** Target machine to monitor
**Runs:**

* Node Exporter (9100)
* Blackbox Exporter (9115)

---

# 🔐 AWS Security Group Setup

---

## 🖥️ Monitoring Server SG

Inbound:

```
SSH (22)      → Your IP
Prometheus    → 9090 (Your IP only)
Grafana       → 3000 (Your IP only)
```

Outbound:

```
All traffic allowed
```

---

## 🌐 Application Server SG

Inbound:

```
SSH (22)            → Your IP
Node Exporter 9100  → Prometheus SG only (NOT 0.0.0.0/0)
Blackbox 9115       → Prometheus SG only (NOT 0.0.0.0/0)
```

Outbound:

```
All traffic allowed
```

---

# 🖥️ MONITORING SERVER (Prometheus + Grafana)

---

## 📦 Step 1: Install Prometheus

```bash
cd /opt

wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz

tar -xvf prometheus-2.54.1.linux-amd64.tar.gz
cd prometheus-2.54.1.linux-amd64

sudo cp prometheus promtool /usr/local/bin/
```

---

## 📁 Step 2: Create directories

```bash
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
```

---

## ⚙️ Step 3: Prometheus config (IMPORTANT)

```bash
sudo nano /etc/prometheus/prometheus.yml
```

---

## ✅ FINAL CONFIG (USE PRIVATE IPS IN PRODUCTION)

```yaml
global:
  scrape_interval: 15s

scrape_configs:

  # -----------------------
  # Prometheus itself
  # -----------------------
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # -----------------------
  # Node Exporter (APP SERVER)
  # -----------------------
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['APP_SERVER_PRIVATE_IP:9100']

  # -----------------------
  # Blackbox Exporter (APP SERVER)
  # -----------------------
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]

    static_configs:
      - targets:
        - http://APP_SERVER_PRIVATE_IP_OR_DOMAIN

    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target

      - source_labels: [__param_target]
        target_label: instance

      - target_label: __address__
        replacement: APP_SERVER_PRIVATE_IP:9115
```

---

## 🚀 Step 4: systemd service

```bash
sudo nano /etc/systemd/system/prometheus.service
```

```ini
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

Restart=always

[Install]
WantedBy=multi-user.target
```

---

## ▶️ Step 5: Start Prometheus

```bash
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

---

## 📊 Step 6: Install Grafana (FIXED - proper repo added)

```bash
sudo apt-get update

sudo apt-get install -y apt-transport-https software-properties-common wget gnupg

sudo mkdir -p /etc/apt/keyrings

wget -q -O - https://apt.grafana.com/gpg.key | \
gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install -y grafana
```

---

## ▶️ Start Grafana

```bash
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Access:

```
http://MONITORING_SERVER_PUBLIC_IP:3000
```

---

# 🌐 APPLICATION SERVER (Node Exporter + Blackbox)

---

## 📦 Step 1: Node Exporter

```bash
cd /opt

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
cd node_exporter-1.8.2.linux-amd64
```

---

## ▶️ Run Node Exporter

```bash
nohup ./node_exporter --web.listen-address="0.0.0.0:9100" > node.log 2>&1 &
```

---

## 📦 Step 2: Blackbox Exporter

```bash
cd /opt

wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz

tar -xvf blackbox_exporter-0.27.0.linux-amd64.tar.gz
cd blackbox_exporter-0.27.0.linux-amd64
```

---

## ▶️ Run Blackbox Exporter

```bash
nohup ./blackbox_exporter --web.listen-address="0.0.0.0:9115" > blackbox.log 2>&1 &
```

---

# 🔍 Verification Commands

---

## On Application Server

```bash
ss -tulnp | grep 9100
ss -tulnp | grep 9115
```

```bash
curl http://localhost:9100/metrics
curl http://localhost:9115/probe?target=google.com&module=http_2xx
```

---

## On Monitoring Server

```bash
curl http://APP_SERVER_PRIVATE_IP:9100/metrics
curl http://APP_SERVER_PRIVATE_IP:9115/probe?target=google.com&module=http_2xx
```

---

# 🎯 FINAL RESULT

| Component         | Server Type       | Port | Status |
| ----------------- | ----------------- | ---- | ------ |
| Prometheus        | Monitoring Server | 9090 | 🟢 UP  |
| Grafana           | Monitoring Server | 3000 | 🟢 UP  |
| Node Exporter     | App Server        | 9100 | 🟢 UP  |
| Blackbox Exporter | App Server        | 9115 | 🟢 UP  |

---

# ⚠️ IMPORTANT (PRODUCTION NOTE)

After testing:

✔ Replace PUBLIC IP → PRIVATE IP (secure VPC setup)
✔ Restrict SG to Prometheus SG only
✔ Replace nohup → systemd services
✔ Avoid exposing exporters publicly

---

# 🚀 RESULT

You now have:

* Fully working AWS monitoring system
* Prometheus scraping real metrics
* Blackbox uptime monitoring
* Grafana visualization ready
* Production-ready architecture foundation

---