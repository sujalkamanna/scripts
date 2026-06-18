# App Server Setup Guide (Ubuntu 24.04)

## Table of Contents

- [App Server Setup Guide (Ubuntu 24.04)](#app-server-setup-guide-ubuntu-2404)
  - [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Architecture](#architecture)
- [EC2 Requirements](#ec2-requirements)
- [Security Group Inbound Rules](#security-group-inbound-rules)
- [Update Server](#update-server)
- [Add Elastic Repository](#add-elastic-repository)
- [Install Filebeat](#install-filebeat)
- [Configure Filebeat](#configure-filebeat)
- [Start Filebeat](#start-filebeat)
- [Clone Java Project](#clone-java-project)
- [Build Project](#build-project)
- [Create Log Directory](#create-log-directory)
- [Run Java Application](#run-java-application)
- [Generate Test Logs](#generate-test-logs)
- [Verify Full Pipeline](#verify-full-pipeline)
- [Additional Resources](#additional-resources)
- [📎 Official Documentation](#-official-documentation)
- [📎 Disclaimer \& Attribution](#-disclaimer--attribution)
- [🎉 Conclusion](#-conclusion)

---

# Overview

This guide explains how to configure an **Application Server (App Server)** for the ELK Stack pipeline.

It covers:

* Java application setup
* Log generation
* Filebeat installation
* Log forwarding to ELK server
* End-to-end observability pipeline

---

# Architecture

```text
Java Application
      ↓
app.log (/opt/app/app.log)
      ↓
Filebeat (App Server)
      ↓
Logstash (ELK Server:5044)
      ↓
Elasticsearch
      ↓
Kibana Dashboard
```

---

# EC2 Requirements

| Component        | Requirement                 |
| ---------------- | --------------------------- |
| Instance Type    | m7-flex.large or equivalent |
| Operating System | Ubuntu 24.04 LTS            |
| Storage          | Minimum 20 GB               |
| RAM              | 4–8 GB recommended          |

---

# Security Group Inbound Rules

| Port | Purpose    | Source |
| ---- | ---------- | ------ |
| 22   | SSH Access | My IP  |

---

# Update Server

Update packages and install dependencies.

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install curl gpg openjdk-17-jdk git maven -y
```

Verify installation:

```bash
java -version
mvn -version
```

---

# Add Elastic Repository

Add Elastic official repository for Filebeat installation.

```bash
sudo install -d -m 0755 /usr/share/keyrings

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
| sudo gpg --dearmor --yes \
-o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
| sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt update
```

---

# Install Filebeat

```bash
sudo apt install filebeat -y
```

---

# Configure Filebeat

Edit configuration file:

```bash
sudo nano /etc/filebeat/filebeat.yml
```

Replace entire file with:

```yaml
filebeat.inputs:

- type: filestream
  id: app-log-input
  enabled: true

  paths:
    - /opt/app/app.log


filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false


setup.template.settings:
  index.number_of_shards: 1


output.logstash:
  hosts: ["ELK_PRIVATE_IP:5044"]


processors:

  - add_host_metadata: ~

  - add_cloud_metadata: ~

  - add_docker_metadata: ~

  - add_kubernetes_metadata: ~


logging.level: info

path.data: /var/lib/filebeat
path.logs: /var/log/filebeat
```

> Replace `ELK_PRIVATE_IP` with your actual ELK server private IP.

---

# Start Filebeat

```bash
sudo systemctl enable filebeat

sudo systemctl restart filebeat
```

Verify:

```bash
sudo filebeat test config
sudo filebeat test output
sudo systemctl status filebeat
```

Expected:

```text
connection... OK
Active: active (running)
```

---

# Clone Java Project

```bash
cd ~

git clone YOUR_GITHUB_REPO_URL

cd PROJECT_NAME
```

Example reference project:

* Boardgame Application: https://github.com/jaiswaladi246/Boardgame

---

# Build Project

Using Maven:

```bash
mvn clean package -DskipTests
```

OR Maven wrapper:

```bash
chmod +x mvnw
./mvnw clean package -DskipTests
```

Expected:

```text
BUILD SUCCESS
```

---

# Create Log Directory

```bash
sudo mkdir -p /opt/app
```

---

# Run Java Application

```bash
nohup java -jar target/*.jar > /opt/app/app.log 2>&1 &
```

Verify:

```bash
ps -ef | grep java
```

Expected:

```text
java -jar
```

---

# Generate Test Logs

```bash
echo "INFO User Login $(date)" >> /opt/app/app.log
echo "ERROR Database Failed $(date)" >> /opt/app/app.log
echo "WARN High Memory Usage $(date)" >> /opt/app/app.log
```

Verify:

```bash
tail -f /opt/app/app.log
```

---

# Verify Full Pipeline

Check Filebeat:

```bash
sudo filebeat test output
sudo systemctl status filebeat
```

Expected:

* Connection OK
* Filebeat active
* Logs successfully forwarded

---

# Additional Resources

| Resource               | URL                                                                        |
| ---------------------- | -------------------------------------------------------------------------- |
| Filebeat Documentation | https://www.elastic.co/guide/en/beats/filebeat/current/index.html          |
| Elastic Stack Docs     | https://www.elastic.co/docs                                                |
| Logstash Documentation | https://www.elastic.co/guide/en/logstash/current/index.html                |
| Elasticsearch Docs     | https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html |
| Kibana Docs            | https://www.elastic.co/guide/en/kibana/current/index.html                  |
| Java Documentation     | https://docs.oracle.com/javase/17/docs/                                    |

---

# 📎 Official Documentation

* https://www.elastic.co/guide/en/beats/filebeat/current/index.html
* https://www.elastic.co/docs
* https://www.elastic.co/guide/en/logstash/current/index.html
* https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
* https://www.elastic.co/guide/en/kibana/current/index.html

---

# 📎 Disclaimer & Attribution

This document is an unofficial educational guide created for learning, DevOps practice, observability setup, log pipeline configuration, and interview preparation.

Primary references include:

* Elastic Documentation
* Java OpenJDK Documentation
* Maven Documentation
* Filebeat Documentation

The ELK Stack is used for centralized logging, monitoring, and observability across distributed systems.

All trademarks belong to their respective owners.

---

# 🎉 Conclusion

```text
Java Application
+
Filebeat
+
Logstash
+
Elasticsearch
+
Kibana
+
Logs
+
Pipelines
+
Observability
+
Monitoring
+
Troubleshooting
```

The App Server setup completes the **end-to-end ELK logging pipeline**, where application logs are generated by a Java application, collected by Filebeat, processed by Logstash, stored in Elasticsearch, and visualized in Kibana dashboards.

This architecture enables real-time monitoring, debugging, and observability for modern distributed applications.

---

```md
**Last Updated:** 2026  
**Platform:** ELK Stack App Server Integration  
**Components:** Java, Filebeat, Logstash, Elasticsearch, Kibana  
**Version:** Elastic Stack 8.x+  
**Environment:** Ubuntu 24.04  

For more information:
https://www.elastic.co/docs
```