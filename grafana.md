# 📊 Grafana Setup on AWS EC2 (Monitoring Server - Production Ready)

This guide installs **Grafana OSS** on a dedicated **Monitoring Server (same server as Prometheus)** and connects it to Prometheus for dashboards like:

* Node Exporter (System Metrics)
* Blackbox Exporter (Uptime / HTTP monitoring)

---

# 🏗️ Architecture

| Server Type                    | Role                                                     |
| ------------------------------ | -------------------------------------------------------- |
| **Application Server (EC2-1)** | Application + Node Exporter                              |
| **Monitoring Server (EC2-2)**  | Prometheus + Grafana + Blackbox Exporter + Node Exporter |

---

# 🔐 AWS Security Group (IMPORTANT)

## 📌 Monitoring Server SG (Grafana + Prometheus)

Inbound:

* SSH (22) → Your IP
* Grafana (3000) → Your IP
* Prometheus (9090) → Your IP

Outbound:

* All traffic allowed

---

## 📌 Application Server SG

Inbound:

* 9100 (Node Exporter) → Monitoring Server Security Group
* SSH (22) → Your IP

---

# 🖥️ Monitoring Server (Grafana + Prometheus)

---

# 📦 Step 1: Install Grafana (Ubuntu / Debian)

```bash
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget gpg

sudo mkdir -p /etc/apt/keyrings/

wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update -y
sudo apt-get install grafana -y
```

---

# 🚀 Step 2: Start Grafana (IMPORTANT - systemd only)

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

---

# 🔍 Step 3: Verify Grafana

```bash
sudo systemctl status grafana-server
```

---

# 🌐 Step 4: Access Grafana

```
http://<MONITORING_SERVER_PUBLIC_IP>:3000
```

### Default Login:

* Username: `admin`
* Password: `admin`

👉 Change password on first login

---

# 🔌 Step 5: Add Prometheus Data Source

Inside Grafana:

1. Go to **Settings → Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. URL:

```
http://localhost:9090
```

5. Click **Save & Test**

---

# 📊 Step 6: Import Prebuilt Dashboards

## Node Exporter Dashboard

* ID: `1860`

## Blackbox Exporter Dashboard

* ID: `7587`

---

### Import Steps:

1. Go to **Dashboards → Import**
2. Enter Dashboard ID
3. Select Prometheus datasource
4. Click **Import**

---

# 🧠 Step 7: Verify Dashboards

You should see:

* Node Exporter Full
* Blackbox Exporter
* Prometheus metrics

---

# 🎯 Final Result

| Component         | Status                                    |
| ----------------- | ----------------------------------------- |
| Grafana           | Running on Monitoring Server (Port 3000)  |
| Prometheus        | Running on Monitoring Server (Port 9090)  |
| Blackbox Exporter | Running on Monitoring Server (Port 9115)  |
| Node Exporter     | Running on Monitoring Server (Port 9100)  |
| Node Exporter     | Running on Application Server (Port 9100) |
| Dashboards        | Fully working                             |

---

# 🚀 Outcome

You now have:

✔ AWS VPC monitoring architecture
✔ Prometheus + Grafana integration
✔ Real-time system metrics from both servers
✔ HTTP uptime monitoring (Blackbox)
✔ Production-grade systemd setup
✔ Public IP based access (no DNS issues)

---