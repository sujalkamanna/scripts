

# Prometheus Monitoring Setup on AWS EC2

This guide explains how to set up **Prometheus** on a monitoring server and **Node Exporter + Blackbox Exporter** on web servers. All steps include running the services in the background using `nohup`.

---

## **Server 1: Monitoring Server (Prometheus only)**

### **Prerequisites**

* EC2 Linux instance (Ubuntu / Amazon Linux 2)
* Security group must allow:

  * SSH (22)
  * Prometheus (9090)

---

### **Step 1: Install Prometheus**

```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xvf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64
```

---

### **Step 2: Run Prometheus in the background**

```bash
nohup prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus >> /var/log/prometheus.log 2>&1 &
```

---

### **Step 3: Prometheus Configuration**

Create or edit `/etc/prometheus/prometheus.yml`. Replace `WEB_SERVER_PRIVATE_IP` and `WEB_SERVER_PUBLIC_IP` with the details of your web server.

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  # Prometheus self metrics
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter on Web server
  - job_name: 'node_exporter_web'
    static_configs:
      - targets: ['WEB_SERVER_PRIVATE_IP:9100']

  # Blackbox Exporter on Web server
  - job_name: 'blackbox_web'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://WEB_SERVER_PUBLIC_IP
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: WEB_SERVER_PRIVATE_IP:9115
```

---

## **Server 2: Web Server (Node Exporter + Blackbox Exporter)**

### **Prerequisites**

* EC2 Linux instance
* Security group must allow:

  * SSH (22)
  * Node Exporter (9100)
  * Blackbox Exporter (9115)

---

### **Step 1: Install Node Exporter**

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64
```

Start Node Exporter in the background:

```bash
nohup node_exporter >> /var/log/node_exporter.log 2>&1 &
```

---

### **Step 2: Install Blackbox Exporter**

```bash
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
tar xvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
cd blackbox_exporter-0.25.0.linux-amd64
```

Start Blackbox Exporter in the background:

```bash
nohup blackbox_exporter >> /var/log/blackbox_exporter.log 2>&1 &
```

---

### **Step 3: Verify Installation**

```bash
# Prometheus UI
curl http://MONITORING_SERVER_PUBLIC_IP:9090

# Node Exporter metrics
curl http://WEB_SERVER_PUBLIC_IP:9100/metrics

# Blackbox Exporter metrics
curl http://WEB_SERVER_PUBLIC_IP:9115/metrics
```

---

### All Command Directly

#### Web Server (Node Exporter + Blackbox Exporter) Only
```bash
nohup blackbox_exporter >> /var/log/blackbox_exporter.log 2>&1 & 
nohup node_exporter >> /var/log/node_exporter.log 2>&1 & 
```

---
