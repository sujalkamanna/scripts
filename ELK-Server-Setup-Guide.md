# ELK Stack Setup Guide (ELK Server Only) - Ubuntu 24.04

## Table of Contents

- [ELK Stack Setup Guide (ELK Server Only) - Ubuntu 24.04](#elk-stack-setup-guide-elk-server-only---ubuntu-2404)
  - [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Architecture](#architecture)
- [EC2 Requirements](#ec2-requirements)
- [Security Group Inbound Rules](#security-group-inbound-rules)
- [Update Server](#update-server)
- [Add Elastic Repository](#add-elastic-repository)
- [Install Elasticsearch, Logstash and Kibana](#install-elasticsearch-logstash-and-kibana)
- [Configure Elasticsearch](#configure-elasticsearch)
- [Configure Elasticsearch Heap](#configure-elasticsearch-heap)
    - [Heap Guidelines](#heap-guidelines)
- [Start Elasticsearch](#start-elasticsearch)
- [Configure Logstash](#configure-logstash)
  - [Validate Configuration](#validate-configuration)
  - [Start Logstash](#start-logstash)
- [Configure Kibana](#configure-kibana)
  - [Start Kibana](#start-kibana)
- [Verify ELK Stack](#verify-elk-stack)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
  - [Elasticsearch Not Starting](#elasticsearch-not-starting)
  - [Logstash Not Listening on 5044](#logstash-not-listening-on-5044)
  - [Kibana Not Loading](#kibana-not-loading)
  - [Verify Elasticsearch Connectivity](#verify-elasticsearch-connectivity)
- [Additional Resources](#additional-resources)
- [📎 Official Documentation](#-official-documentation)
- [📎 Disclaimer \& Attribution](#-disclaimer--attribution)
- [🎉 Conclusion](#-conclusion)

---

# Overview

The ELK Stack is a centralized logging and observability platform consisting of:

* Elasticsearch (Storage & Search Engine)
* Logstash (Log Processing Pipeline)
* Kibana (Visualization & Dashboarding)

This guide covers the installation and configuration of an ELK Server on Ubuntu 24.04 for receiving logs from application servers and visualizing them through Kibana.

---

# Architecture

```text
Application Servers
       │
       │ Filebeat
       ▼
Logstash (Port 5044)
       │
       ▼
Elasticsearch (Port 9200)
       │
       ▼
Kibana Dashboard (Port 5601)
```

---

# EC2 Requirements

| Component        | Requirement                 |
| ---------------- | --------------------------- |
| Instance Type    | m7-flex.large or equivalent |
| Operating System | Ubuntu 24.04 LTS            |
| Storage          | Minimum 30 GB               |
| Memory           | Recommended 8 GB+           |
| CPU              | 2 vCPU or higher            |

---

# Security Group Inbound Rules

| Port | Purpose                      | Source                            |
| ---- | ---------------------------- | --------------------------------- |
| 22   | SSH                          | My IP                             |
| 5044 | Logstash Beats Input         | Application Server Security Group |
| 5601 | Kibana Dashboard             | My IP                             |
| 9200 | Elasticsearch API (Optional) | My IP                             |

---

# Update Server

Update the operating system and install required packages.

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install curl gpg apt-transport-https unzip -y
```

---

# Add Elastic Repository

Add the official Elastic repository.

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

# Install Elasticsearch, Logstash and Kibana

Install all ELK components.

```bash
sudo apt install elasticsearch logstash kibana -y
```

---

# Configure Elasticsearch

Edit the Elasticsearch configuration file.

```bash
sudo nano /etc/elasticsearch/elasticsearch.yml
```

Replace the contents with:

```yaml
cluster.name: elk-cluster

node.name: elk-stack-server

path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

network.host: 0.0.0.0
http.port: 9200

discovery.type: single-node

xpack.security.enabled: false
xpack.security.enrollment.enabled: false

xpack.security.http.ssl:
  enabled: false

xpack.security.transport.ssl:
  enabled: false
```

> Note: Security is disabled for lab and learning environments. Enable authentication and TLS for production deployments.

---

# Configure Elasticsearch Heap

Create a custom heap configuration.

```bash
sudo nano /etc/elasticsearch/jvm.options.d/heap.options
```

Add:

```text
-Xms2g
-Xmx2g
```

### Heap Guidelines

| Server RAM | Recommended Heap |
| ---------- | ---------------- |
| 4 GB       | 1 GB             |
| 8 GB       | 2 GB             |
| 16 GB      | 4 GB             |
| 32 GB      | 8 GB             |

---

# Start Elasticsearch

Enable and start the service.

```bash
sudo systemctl daemon-reload

sudo systemctl enable elasticsearch

sudo systemctl restart elasticsearch
```

Verify:

```bash
curl http://localhost:9200
```

Expected Response:

```json
{
  "name": "elk-stack-server",
  "cluster_name": "elk-cluster"
}
```

External Access:

```text
http://ELK_PUBLIC_IP:9200
```

---

# Configure Logstash

Create a Logstash pipeline.

```bash
sudo nano /etc/logstash/conf.d/logstash.conf
```

Add:

```ruby
input {

  beats {

    host => "0.0.0.0"
    port => 5044

  }

}

filter {

  grok {

    match => {

      "message" =>
      "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}"

    }

  }

}

output {

  elasticsearch {

    hosts => ["http://localhost:9200"]

    index => "application-logs-%{+YYYY.MM.dd}"

  }

  stdout {

    codec => rubydebug

  }

}
```

---

## Validate Configuration

```bash
sudo /usr/share/logstash/bin/logstash \
--config.test_and_exit \
-f /etc/logstash/conf.d/logstash.conf
```

Expected:

```text
Configuration OK
```

---

## Start Logstash

```bash
sudo systemctl enable logstash

sudo systemctl restart logstash
```

Verify:

```bash
sudo ss -tulnp | grep 5044
```

Expected:

```text
*:5044
```

---

# Configure Kibana

Edit:

```bash
sudo nano /etc/kibana/kibana.yml
```

Replace with:

```yaml
server.port: 5601

server.host: "0.0.0.0"

server.name: "elk-stack-server"

elasticsearch.hosts:
  - "http://localhost:9200"

monitoring.ui.container.elasticsearch.enabled: true

logging:

  appenders:

    file:

      type: file

      fileName: /var/log/kibana/kibana.log

      layout:
        type: json

  root:

    appenders:
      - default
      - file

    level: info

pid.file: /run/kibana/kibana.pid

path.data: /var/lib/kibana
```

---

## Start Kibana

```bash
sudo systemctl enable kibana

sudo systemctl restart kibana
```

Verify:

```bash
sudo systemctl status kibana
```

Access Kibana:

```text
http://ELK_PUBLIC_IP:5601
```

---

# Verify ELK Stack

Check Elasticsearch:

```bash
curl http://localhost:9200
```

Check Services:

```bash
sudo systemctl status elasticsearch

sudo systemctl status logstash

sudo systemctl status kibana
```

Verify Listening Ports:

```bash
sudo ss -tulnp | grep -E "9200|5601|5044"
```

Expected:

```text
9200 -> Elasticsearch
5044 -> Logstash
5601 -> Kibana
```

---

# Best Practices

* Use dedicated storage volumes for Elasticsearch data.
* Keep JVM heap below 50% of available RAM.
* Restrict Elasticsearch access using Security Groups.
* Enable TLS and authentication in production.
* Configure regular snapshots and backups.
* Monitor disk usage and index growth.
* Use index lifecycle management (ILM).
* Separate ELK workloads from application workloads.
* Rotate and archive old indices.
* Secure Kibana with authentication.

---

# Troubleshooting

## Elasticsearch Not Starting

Check logs:

```bash
sudo journalctl -u elasticsearch -n 100
```

Or:

```bash
sudo tail -f /var/log/elasticsearch/*.log
```

---

## Logstash Not Listening on 5044

Validate configuration:

```bash
sudo /usr/share/logstash/bin/logstash \
--config.test_and_exit \
-f /etc/logstash/conf.d/logstash.conf
```

Check logs:

```bash
sudo journalctl -u logstash -n 100
```

---

## Kibana Not Loading

Check:

```bash
sudo systemctl status kibana
```

View logs:

```bash
sudo tail -f /var/log/kibana/kibana.log
```

---

## Verify Elasticsearch Connectivity

```bash
curl http://localhost:9200
```

Expected:

```json
{
  "status": "green"
}
```

---

# Additional Resources

| Resource                    | URL                                                                        |
| --------------------------- | -------------------------------------------------------------------------- |
| Elastic Documentation       | https://www.elastic.co/docs                                                |
| Elasticsearch Documentation | https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html |
| Logstash Documentation      | https://www.elastic.co/guide/en/logstash/current/index.html                |
| Kibana Documentation        | https://www.elastic.co/guide/en/kibana/current/index.html                  |
| Beats Documentation         | https://www.elastic.co/guide/en/beats/index.html                           |
| Filebeat Documentation      | https://www.elastic.co/guide/en/beats/filebeat/current/index.html          |
| Elastic Observability       | https://www.elastic.co/observability                                       |
| Elastic Security            | https://www.elastic.co/security                                            |
| Elastic Training            | https://www.elastic.co/training                                            |

---

# 📎 Official Documentation

* https://www.elastic.co/docs
* https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
* https://www.elastic.co/guide/en/logstash/current/index.html
* https://www.elastic.co/guide/en/kibana/current/index.html
* https://www.elastic.co/guide/en/beats/index.html
* https://www.elastic.co/guide/en/beats/filebeat/current/index.html

---

# 📎 Disclaimer & Attribution

This document is an unofficial educational guide created for learning, revision, interview preparation, observability implementation, centralized logging, DevOps engineering, platform engineering, cloud engineering, and site reliability engineering (SRE).

Primary references include:

* Elastic Documentation
* Elasticsearch Documentation
* Logstash Documentation
* Kibana Documentation
* Beats Documentation
* Filebeat Documentation

The Elastic Stack (ELK Stack) is a widely adopted platform for centralized logging, search, analytics, observability, and security monitoring.

All trademarks, product names, and service names belong to their respective owners.

For authoritative information, always refer to official Elastic documentation.

---

# 🎉 Conclusion

```text
Elasticsearch
+
Logstash
+
Kibana
+
Beats
+
Filebeat
+
Indexes
+
Search
+
Analytics
+
Dashboards
+
Observability
+
Infrastructure Monitoring
+
Application Monitoring
+
Centralized Logging
```

The ELK Stack provides a powerful centralized logging and observability platform for modern applications and infrastructure.

By combining Elasticsearch for storage and search, Logstash for processing, and Kibana for visualization, organizations can build scalable logging platforms capable of collecting, analyzing, and visualizing data from multiple systems in real time.

This setup serves as a foundation for integrating Filebeat, application logging, infrastructure monitoring, security analytics, and enterprise observability solutions.

---

```md
**Last Updated:** 2026
**Platform:** Elastic Stack (ELK)
**Components:** Elasticsearch, Logstash, Kibana
**Version:** Elastic Stack 8.x+
**License:** Elastic License / Open Source Components

For the latest information, visit:
https://www.elastic.co/docs
```