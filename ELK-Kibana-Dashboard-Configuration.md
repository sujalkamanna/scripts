# Kibana Data View and Dashboard Configuration Guide

## Table of Contents

- [Kibana Data View and Dashboard Configuration Guide](#kibana-data-view-and-dashboard-configuration-guide)
  - [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Access Kibana](#access-kibana)
- [Create Data View](#create-data-view)
  - [Data View Configuration](#data-view-configuration)
  - [Save](#save)
- [Verify Data View in Discover](#verify-data-view-in-discover)
  - [Time Filter](#time-filter)
  - [Expected Logs](#expected-logs)
- [Add Useful Columns](#add-useful-columns)
- [Create Dashboard](#create-dashboard)
- [Visualizations](#visualizations)
  - [1. Log Level Distribution (Pie Chart)](#1-log-level-distribution-pie-chart)
  - [2. Logs Over Time](#2-logs-over-time)
  - [3. Error Logs Table](#3-error-logs-table)
  - [4. Host Activity](#4-host-activity)
- [Build Final Dashboard](#build-final-dashboard)
  - [Dashboard Name](#dashboard-name)
- [Live Testing](#live-testing)
- [End-to-End Flow](#end-to-end-flow)
- [Additional Resources](#additional-resources)
- [📎 Official Documentation](#-official-documentation)
- [📎 Disclaimer \& Attribution](#-disclaimer--attribution)
- [🎉 Conclusion](#-conclusion)

---

# Overview

This guide explains how to configure **Kibana Data Views and Dashboards** for visualizing logs stored in Elasticsearch as part of the ELK Stack.

You will learn how to:

* Create a Data View
* Explore logs in Discover
* Build dashboards
* Create visualizations
* Monitor application logs in real time

---

# Access Kibana

Open Kibana in your browser:

```text
http://ELK_PUBLIC_IP:5601
```

Ensure:

* Elasticsearch is running
* Logstash is receiving logs
* Filebeat is forwarding logs (if configured)

---

# Create Data View

Navigate:

```text
☰ Menu → Stack Management → Data Views → Create Data View
```

## Data View Configuration

| Field           | Value              |
| --------------- | ------------------ |
| Name            | Boardgame Logs     |
| Index Pattern   | application-logs-* |
| Timestamp Field | @timestamp         |

## Save

Click:

```text
Save Data View
```

---

# Verify Data View in Discover

Navigate:

```text
☰ Menu → Discover
```

Select:

```text
Boardgame Logs
```

## Time Filter

Change time range:

* Last 15 minutes
* Last 24 hours
* Last 7 days

Click:

```text
Refresh
```

## Expected Logs

```text
INFO User Login
ERROR Database Failed
WARN High Memory Usage
```

---

# Add Useful Columns

In **Discover**, add the following fields:

* message
* host.name
* log.file.path
* @timestamp
* level

Click **+** to add each field as a column.

---

# Create Dashboard

Navigate:

```text
☰ Menu → Analytics → Dashboard → Create Dashboard
```

Click:

```text
Create Visualization
```

---

# Visualizations

## 1. Log Level Distribution (Pie Chart)

* Visualization Type: Pie Chart
* Data View: Boardgame Logs
* Metric: Count
* Slice By: `level.keyword`

Save as:

```text
Log Level Distribution
```

---

## 2. Logs Over Time

* Visualization Type: Line Chart
* X-axis: @timestamp
* Y-axis: Count

Save as:

```text
Logs Over Time
```

---

## 3. Error Logs Table

* Visualization Type: Data Table
* Filter: `message : ERROR`

Columns:

* message
* host.name
* @timestamp

Save as:

```text
Error Logs Table
```

---

## 4. Host Activity

* Visualization Type: Bar Chart
* X-axis: host.name
* Y-axis: Count

Save as:

```text
Host Activity
```

---

# Build Final Dashboard

Add all visualizations:

* Log Level Distribution
* Logs Over Time
* Error Logs Table
* Host Activity

Arrange layout and click:

```text
Save Dashboard
```

## Dashboard Name

```text
Boardgame Monitoring Dashboard
```

---

# Live Testing

Run the following on your application server:

```bash
echo "INFO User Login $(date)" >> /opt/app/app.log
echo "ERROR Payment Failed $(date)" >> /opt/app/app.log
echo "WARN Memory High $(date)" >> /opt/app/app.log
```

Then:

* Go to Kibana Dashboard
* Click Refresh
* Verify real-time logs

---

# End-to-End Flow

```text
Java Application
      ↓
app.log
      ↓
Filebeat
      ↓
Logstash (5044)
      ↓
Elasticsearch (9200)
      ↓
Kibana Data View
      ↓
Dashboards & Visualizations
```

---

# Additional Resources

| Resource              | URL                                                                        |
| --------------------- | -------------------------------------------------------------------------- |
| Kibana Documentation  | https://www.elastic.co/guide/en/kibana/current/index.html                  |
| Elastic Stack Docs    | https://www.elastic.co/docs                                                |
| Elasticsearch Docs    | https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html |
| Logstash Docs         | https://www.elastic.co/guide/en/logstash/current/index.html                |
| Filebeat Docs         | https://www.elastic.co/guide/en/beats/filebeat/current/index.html          |
| Elastic Observability | https://www.elastic.co/observability                                       |
| Elastic Training      | https://www.elastic.co/training                                            |

---

# 📎 Official Documentation

* https://www.elastic.co/guide/en/kibana/current/index.html
* https://www.elastic.co/docs
* https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
* https://www.elastic.co/guide/en/logstash/current/index.html

---

# 📎 Disclaimer & Attribution

This document is an unofficial educational guide created for learning, revision, interview preparation, observability, log analytics, DevOps engineering, platform engineering, cloud engineering, and site reliability engineering (SRE).

Primary references include:

* Elastic Documentation
* Kibana Documentation
* Elasticsearch Documentation
* Logstash Documentation
* Filebeat Documentation

The ELK Stack is a centralized logging and observability platform used for collecting, processing, indexing, and visualizing log data across distributed systems.

All trademarks and product names belong to their respective owners.

---

# 🎉 Conclusion

```text
Kibana
+
Data Views
+
Discover
+
Dashboards
+
Visualizations
+
Filters
+
Time Series Analysis
+
Log Monitoring
+
Error Tracking
+
Host Monitoring
```

Kibana provides a powerful visualization layer for the ELK Stack, enabling real-time exploration and monitoring of logs stored in Elasticsearch.

With Data Views, Discover, and Dashboards, teams can quickly analyze logs, detect issues, and build operational visibility across applications and infrastructure.

---

```md
**Last Updated:** 2026  
**Platform:** Kibana (Elastic Stack)  
**Version:** 8.x+  
**Component:** Visualization & Dashboarding Layer  
**License:** Elastic License / Open Source Components  

For the latest information, visit:
https://www.elastic.co/docs
```