# New Relic Account & Agent Setup Guide

## Table of Contents

1. [Create a New Relic Account](#create-a-new-relic-account)
2. [Explore the New Relic Dashboard](#explore-the-new-relic-dashboard)
3. [Install the Infrastructure Agent](#install-the-infrastructure-agent)
4. [Verify Infrastructure Monitoring](#verify-infrastructure-monitoring)
5. [Install an Application Monitoring Agent](#install-an-application-monitoring-agent)
6. [Java Application Monitoring Example](#java-application-monitoring-example)
7. [Explore Metrics, Logs, Errors, and Traces](#explore-metrics-logs-errors-and-traces)
8. [Create Dashboards](#create-dashboards)

---

## Create a New Relic Account

1. Visit **[https://open.newrelic.com](https://open.newrelic.com)**.
2. Create your **Free Tier** New Relic account.
3. The Free Tier includes a monthly data ingestion allowance (check the latest limits in your account plan details).
4. Complete the account registration process.

✅ Your New Relic account is now ready.

---

## Explore the New Relic Dashboard

After logging in:

1. Open the New Relic dashboard.

2. Familiarize yourself with the available sections:

   * Infrastructure
   * APM (Application Performance Monitoring)
   * Logs
   * Dashboards
   * Alerts
   * Distributed Tracing

3. Navigate to **Agents** to begin installing monitoring agents.

---

## Install the Infrastructure Agent

The Infrastructure Agent allows you to monitor servers, virtual machines, containers, and cloud resources.

### Supported Environments

You can install the Infrastructure Agent on:

* Linux
* Ubuntu
* Red Hat Enterprise Linux (RHEL)
* Windows
* Docker
* Other supported operating systems

It supports:

* Cloud providers (AWS, Azure, GCP, etc.)
* On-premises servers
* Virtual machines
* Containers

### Installation Steps

1. Navigate to **Agents** in New Relic.
2. Select **Infrastructure Agent**.
3. Choose your host operating system.
4. Follow the installation wizard.
5. Copy the generated installation commands.
6. Execute the commands on your target host using the command line interface (CLI).
7. Complete the installation process.

---

## Verify Infrastructure Monitoring

After installation:

1. Return to New Relic.
2. Check the Infrastructure page.
3. Verify that the host status shows **Connected**.

If connected successfully, you should be able to view:

* CPU usage
* Memory utilization
* Disk metrics
* Network metrics
* Infrastructure logs

### Review Infrastructure Data

Explore:

* Host overview
* Infrastructure metrics
* Logs
* Health status
* Resource utilization trends

✅ Infrastructure monitoring is now configured.

---

## Install an Application Monitoring Agent

Next, configure application performance monitoring (APM).

### Supported Languages

Examples include:

* Java
* Python
* Node.js
* .NET
* PHP
* Ruby
* Go

For this guide, we'll use **Java** as an example.

---

## Java Application Monitoring Example

### Step 1: Select Java

1. Navigate to **Agents**.
2. Choose **Java** from the list of available agents.

### Step 2: Choose Your Application Type

Select the appropriate Java framework or application server, such as:

* Spring Boot
* Apache Tomcat
* Jetty
* JBoss/WildFly
* Other supported Java platforms

### Step 3: Follow the Installation Wizard

1. Follow the provided setup instructions.
2. Generate the required license key and configuration.
3. Download the Java agent package.
4. Update the configuration file as instructed.
5. Add the Java agent startup parameters to your application.

### Step 4: Start the Application

1. Restart or launch your Java application.
2. Allow the application to send telemetry data to New Relic.

### Step 5: Test the Connection

1. Return to New Relic.
2. Verify that the application appears in APM.
3. Confirm that telemetry data is being received.

✅ Java application monitoring is now configured.

---

## Explore Metrics, Logs, Errors, and Traces

Once the Java agent is connected, you can analyze:

### Metrics

* Throughput
* Response time
* JVM performance
* Database performance
* External service calls

### Logs

* Application logs
* Error logs
* Infrastructure logs

### Errors

* Exception tracking
* Error rates
* Error analytics

### Distributed Tracing

* End-to-end request flow
* Service dependencies
* Performance bottlenecks

---

## Create Dashboards

New Relic provides both pre-built and custom dashboards.

### Option 1: Use Pre-Built Dashboards

Infrastructure and Java APM dashboards are automatically available after agent installation.

1. Navigate to **Dashboards**.
2. Select a pre-built dashboard.
3. Assign a name if required.
4. Save the dashboard.

### Option 2: Create a Custom Dashboard

1. Go to **Dashboards**.
2. Click **Create Dashboard**.
3. Enter a dashboard name.
4. Add widgets for:

   * Infrastructure metrics
   * Application metrics
   * Logs
   * Errors
   * Traces
5. Save the dashboard.

✅ Dashboard setup is complete.

---

# Summary

1. Create a New Relic account.
2. Explore the New Relic dashboard.
3. Install the Infrastructure Agent.
4. Verify infrastructure monitoring.
5. Install an application monitoring agent (Java example).
6. Validate the connection.
7. Explore metrics, logs, errors, and traces.
8. Create pre-built or custom dashboards.

🎉 Your New Relic observability environment is now ready for infrastructure and application monitoring.

# Additional Resources

| Resource                       | URL                                                                          |
| ------------------------------ | ---------------------------------------------------------------------------- |
| New Relic Documentation        | https://docs.newrelic.com                                                    |
| New Relic One Platform         | https://one.newrelic.com                                                     |
| Infrastructure Monitoring Docs | https://docs.newrelic.com/docs/infrastructure                                |
| APM Documentation              | https://docs.newrelic.com/docs/apm                                           |
| Logs Documentation             | https://docs.newrelic.com/docs/logs                                          |
| Distributed Tracing Docs       | https://docs.newrelic.com/docs/distributed-tracing                           |
| Dashboards Documentation       | https://docs.newrelic.com/docs/query-your-data/explore-query-data/dashboards |
| Alerts & Applied Intelligence  | https://docs.newrelic.com/docs/alerts-applied-intelligence                   |
| OpenTelemetry Integration      | https://docs.newrelic.com/docs/opentelemetry                                 |
| New Relic University           | https://learn.newrelic.com                                                   |

---

# 📎 Official Documentation

* [New Relic Documentation](https://docs.newrelic.com/)
* [New Relic One Platform](https://one.newrelic.com/)
* [Infrastructure Monitoring Documentation](https://docs.newrelic.com/docs/infrastructure/)
* [Application Performance Monitoring (APM)](https://docs.newrelic.com/docs/apm/)
* [Logs Documentation](https://docs.newrelic.com/docs/logs/)
* [Distributed Tracing Documentation](https://docs.newrelic.com/docs/distributed-tracing/)
* [Dashboards Documentation](https://docs.newrelic.com/docs/query-your-data/explore-query-data/dashboards/)
* [Alerts & Applied Intelligence](https://docs.newrelic.com/docs/alerts-applied-intelligence/)
* [OpenTelemetry Documentation](https://docs.newrelic.com/docs/opentelemetry/)
* [New Relic University](https://learn.newrelic.com/)

---

# 📎 Disclaimer & Attribution

This document is an unofficial educational guide created for learning, revision, observability adoption, monitoring implementation, DevOps engineering, platform engineering, cloud engineering, site reliability engineering (SRE), infrastructure monitoring, application performance monitoring (APM), and cloud-native operations.

Primary references include:

* New Relic Documentation
* New Relic Infrastructure Documentation
* New Relic APM Documentation
* New Relic Logs Documentation
* New Relic Distributed Tracing Documentation
* OpenTelemetry Documentation
* New Relic University

New Relic is an observability platform that provides monitoring, logging, tracing, alerting, and analytics capabilities for applications, infrastructure, and cloud environments.

All trademarks, product names, and service names belong to their respective owners.

For authoritative information, always refer to the official New Relic documentation.

---

# 🎉 Conclusion

```text
Infrastructure Monitoring
+
Application Performance Monitoring (APM)
+
Logs
+
Metrics
+
Distributed Tracing
+
Dashboards
+
Alerts
+
OpenTelemetry
+
Cloud Monitoring
+
Observability
+
Performance Optimization
+
Incident Management
```

New Relic provides a comprehensive observability platform for monitoring infrastructure, applications, containers, Kubernetes clusters, cloud services, logs, traces, and business-critical systems across modern distributed environments.

By combining infrastructure monitoring, APM, logging, distributed tracing, dashboards, and intelligent alerting, teams can proactively detect issues, improve reliability, and optimize performance at scale.

---

```md
**Last Updated:** 2026
**Platform:** New Relic
**Version:** Current SaaS Release
**License:** Commercial SaaS Platform (Free Tier Available)

For the latest information, visit https://docs.newrelic.com/
```