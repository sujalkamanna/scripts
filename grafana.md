# **Installing Grafana on Monitoring Server ( Prebuilt Dashboards)**

### **Step 0: Prerequisites**

* EC2 Linux instance (Ubuntu / Amazon Linux 2)
* Security group must allow:

  * SSH (22)
  * Grafana (3000)
* Prometheus must already be installed and running.

---

### **Step 1: Install Grafana**

> **Note:** These steps are for **Grafana OSS, Version 12.3.1**

**Ubuntu / Debian:**

```bash
sudo apt-get update
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/grafana/release/12.3.1/grafana_12.3.1_20271043721_linux_amd64.deb
sudo dpkg -i grafana_12.3.1_20271043721_linux_amd64.deb
```

**Amazon Linux 2 / RHEL / CentOS:**

```bash
sudo yum install -y https://dl.grafana.com/oss/release/grafana-9.5.3-1.x86_64.rpm
```

---

### **Step 2: Start Grafana in the background**

```bash
nohup grafana-server --homepath=/usr/share/grafana >> /var/log/grafana.log 2>&1 &
```

---

### **Step 3: Enable Grafana to start on boot (optional)**

```bash
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

---

### **Step 4: Access Grafana**

* Open browser: `http://MONITORING_SERVER_PUBLIC_IP:3000`
* Default login credentials:

  * Username: `admin`
  * Password: `admin`
* You will be prompted to change the password on first login.

---

### **Step 5: Add Prometheus as a Data Source**

1. Login to Grafana
2. Navigate to **Configuration → Data Sources → Add Data Source**
3. Select **Prometheus**
4. Set URL: `http://localhost:9090`
5. Click **Save & Test**

---

### **Step 6: Import Prebuilt Dashboards**

Grafana dashboards can be imported using the **dashboard ID from Grafana.com**.

| Dashboard             | ID   |
| -----------------     | ---- |
| Node Exporter         | 1860 |
| Blackbox Exporter     | 7587 |

#### **Option 1: Manual Import**

1. Go to **Create → Import**
2. Enter the **Dashboard ID** (1860 for Node Exporter, 7587 for Blackbox Exporter)
3. Select **Prometheus** as the data source
4. Click **Import**

#### **Option 2: Import via JSON / CLI**

You can also download the dashboard JSON and import via Grafana API:

```bash
# Node Exporter
curl -X POST -H "Content-Type: application/json" \
     -d @node_exporter_dashboard.json \
     http://admin:YOUR_PASSWORD@localhost:3000/api/dashboards/db

# Blackbox Exporter
curl -X POST -H "Content-Type: application/json" \
     -d @blackbox_exporter_dashboard.json \
     http://admin:YOUR_PASSWORD@localhost:3000/api/dashboards/db
```

> Replace `YOUR_PASSWORD` with your Grafana admin password.
> Save the dashboard JSON files from [Grafana.com Dashboards](https://grafana.com/grafana/dashboards/).

---

### **Step 7: Verify Dashboards**

1. Open Grafana: `http://MONITORING_SERVER_PUBLIC_IP:3000`
2. Navigate to **Dashboards → Manage**
3. You should see the following dashboards:

   * Node Exporter Full
   * Blackbox Exporter

---

✅ **Result:** Grafana is now installed, running in the background, connected to Prometheus, and prebuilt dashboards for Node Exporter and Blackbox Exporter are ready to use.
