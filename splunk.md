# Splunk Monitoring Guide

## Overview

This guide provides a practical and conceptual understanding of Splunk, a widely used monitoring and log management tool in modern IT environments. It is designed for developers, testers, DevOps engineers, and operations teams who need to monitor applications, troubleshoot issues, and analyze logs efficiently.

---

## Why Monitoring Matters

Monitoring is a core responsibility across all IT roles—not just DevOps. It helps in:

* Tracking application health
* Detecting errors and failures
* Monitoring infrastructure (compute, storage, databases)
* Enhancing system security
* Improving troubleshooting and incident response

Adding monitoring tools like Splunk to your skillset is highly valuable for career growth.

---

## How Monitoring Tools Work

Most monitoring tools (Splunk, Datadog, CloudWatch, Grafana, Kibana, New Relic) follow the same architecture:

### 1. Source (Data Input)

* Servers or applications where logs are generated
* Example: Linux servers, cloud instances, applications

### 2. Forwarder (Agent)

* Lightweight agent installed on the source
* Collects logs and forwards them to the central system

### 3. Indexing

* Logs are structured with metadata like:

  * Timestamp
  * Log level (error, info, warning)
  * Event details
* Enables fast searching and filtering

### 4. Dashboard (Visualization)

* Web-based UI to view logs and metrics
* Eliminates need for direct server access
* Improves security and usability

---

## Splunk Architecture

* Splunk Enterprise: Installed and managed on your own infrastructure
* Splunk Cloud: Fully managed cloud-based solution

### Key Components:

* Splunk Server (Indexer + UI)
* Splunk Forwarder (Log collector)
* Data Sources (/var/log, application logs, etc.)

---

## Default Log Locations

On Linux systems, most logs are stored in:

```bash
/var/log
```

This is the primary directory configured for monitoring.

---

## Installation Guide (Splunk Enterprise - Ubuntu 24.04+)

### 1. Launch Server

* Use cloud VM (e.g., AWS EC2)
* Recommended: t3.medium (or equivalent)
* Ubuntu 24.04 LTS

---

### 2. Update Server

```bash
sudo apt update && sudo apt upgrade -y
```

Install basic utilities:

```bash
sudo apt install wget curl unzip net-tools -y
```

---

### 3. Download Splunk

```bash
wget -O splunk.deb "https://download.splunk.com/products/splunk/releases/<version>/linux/splunk-<version>-linux-amd64.deb"
```

---

### 4. Install Splunk

```bash
sudo dpkg -i splunk.deb
```

If dependencies are missing:

```bash
sudo apt --fix-broken install -y
```

---

### 5. Start Splunk

```bash
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes
```

Set credentials:

* Username: admin
* Password: minimum 8 characters

---

### 6. Enable Auto Start

```bash
cd /opt/splunk/bin

sudo ./splunk enable boot-start
```

✔ Starts automatically after reboot

✔ Runs like a service

---

### 7. Important Ports

| Port | Purpose             |
| ---- | ------------------- |
| 8000 | Web UI              |
| 8089 | Management          |
| 9997 | Forwarder Receiving |

---

### 8. Open Firewall Ports (UFW)

```bash
sudo ufw allow 8000/tcp
sudo ufw allow 8089/tcp
sudo ufw allow 9997/tcp
sudo ufw reload
```

---

### 9. Enable Receiving From Forwarders

```bash
sudo /opt/splunk/bin/splunk enable listen 9997
```

---

### 10. Access Dashboard

Open in browser:

```bash
http://<public-ip>:8000
```

---

### 11. Optimize Settings

Go to:

Settings → Server Settings → General

Reduce memory usage (for example 5000 MB → 500 MB on small lab servers)

---

## Splunk Forwarder Setup

### 1. Download Forwarder

```bash
wget -O splunkforwarder.deb "https://download.splunk.com/products/universalforwarder/releases/<version>/linux/splunkforwarder-<version>-linux-amd64.deb"
```

---

### 2. Install

```bash
sudo dpkg -i splunkforwarder.deb
```

If dependencies are missing:

```bash
sudo apt --fix-broken install -y
```

---

### 3. Start Forwarder

```bash
sudo /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes
```

---

### 4. Enable Auto Start

```bash
sudo /opt/splunkforwarder/bin/splunk enable boot-start
```

---

### 5. Connect to Splunk Server

```bash
sudo /opt/splunkforwarder/bin/splunk add forward-server <splunk-public-ip>:9997
```

Example:

```bash
sudo /opt/splunkforwarder/bin/splunk add forward-server 10.0.1.10:9997
```

---

### 6. Configure Log Monitoring

Monitor all Linux logs:

```bash
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log
```

Monitor only system logs:

```bash
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/syslog
```

Monitor authentication logs:

```bash
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log
```

---

## Ubuntu Log Locations

| Log File                    | Purpose               |
| --------------------------- | --------------------- |
| /var/log/syslog             | General System Logs   |
| /var/log/auth.log           | Authentication Events |
| /var/log/kern.log           | Kernel Messages       |
| /var/log/dpkg.log           | Package Installations |
| /var/log/apache2/access.log | Apache Access Logs    |
| /var/log/apache2/error.log  | Apache Errors         |
| /var/log/nginx/access.log   | Nginx Access Logs     |
| /var/log/nginx/error.log    | Nginx Errors          |

---

## Log Monitoring in Action

Splunk can monitor:

* Application logs
* Apache/Nginx logs
* System logs
* Custom logs (e.g., Python scripts)

### Example Use Cases

* Track HTTP requests
* Detect application errors
* Monitor service start/stop events
* Debug production issues

---

## Scaling with Multiple Servers

For large environments:

* Install forwarders on all servers
* Use tools like Ansible for automation
* Centralize logs in one Splunk instance

---

## Splunk vs Other Monitoring Tools

| Feature         | Splunk Enterprise | Splunk Cloud | Other Tools   |
| --------------- | ----------------- | ------------ | ------------- |
| Setup           | Manual            | Managed      | Varies        |
| Maintenance     | User              | Provider     | Depends       |
| Data Collection | Forwarder         | Agent        | Agent-Based   |
| UI              | Web Dashboard     | Cloud UI     | Web/Cloud     |
| Log Processing  | Built-In          | Built-In     | Tool-Specific |

---

## Best Practices

* Always monitor `/var/log`
* Restrict direct server access; use dashboards
* Structure logs properly for better querying
* Automate forwarder deployment
* Use dashboards for real-time insights
* Combine with metrics tools (Grafana/Prometheus) for full observability
* Enable SSL/TLS communication between forwarders and Splunk
* Back up Splunk configurations regularly

---

## Key Takeaways

* Monitoring is essential across all IT roles
* Splunk simplifies log analysis and troubleshooting
* All monitoring tools share similar architecture
* Learning Splunk makes it easier to learn other tools
* Dashboards improve both security and efficiency

---

## Conclusion

Splunk is a powerful log monitoring and analysis tool that enables real-time visibility into applications and systems. By understanding its architecture, installation, and usage, you can efficiently monitor infrastructure, troubleshoot issues, and improve system reliability.

**Mastering Splunk provides a strong foundation for working with any modern monitoring or observability tool.**