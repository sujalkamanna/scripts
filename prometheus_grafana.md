Here's your complete, properly formatted `README.md` file:

---

# 📊 Kubernetes Monitoring Stack

A complete guide to set up **Prometheus** and **Grafana** monitoring on Kubernetes using Helm.

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
  - [1. Install Helm](#1-install-helm)
  - [2. Install Metrics Server](#2-install-metrics-server)
  - [3. Add Helm Repositories](#3-add-helm-repositories)
  - [4. Create Namespaces](#4-create-namespaces)
  - [5. Install Prometheus](#5-install-prometheus)
  - [6. Install Grafana](#6-install-grafana)
- [Configuration](#%EF%B8%8F-configuration)
  - [Access Grafana](#access-grafana)
  - [Add Prometheus Data Source](#add-prometheus-data-source)
  - [Import Dashboards](#import-dashboards)
- [Troubleshooting](#-troubleshooting)
- [Security Best Practices](#-security-best-practices)
- [Custom Dashboards](#-custom-dashboards)
- [Useful Commands](#-useful-commands)
- [Version Information](#-version-information)
- [Upgrade Guide](#-upgrade-guide)
- [Quick Reference](#-quick-reference)
- [Cleanup](#-cleanup)
- [Contributing](#-contributing)
- [Support](#-support)
- [Acknowledgments](#-acknowledgments)
- [License](#-license)

---

## 🔧 Prerequisites

Before you begin, ensure you have:

- ✅ A running Kubernetes cluster
- ✅ `kubectl` installed and configured
- ✅ Cluster admin permissions
- ✅ AWS EKS with `gp2` storage class *(or modify for your cloud provider)*

---

## 🚀 Installation

### 1. Install Helm

Download and install Helm package manager:

```bash
# Download Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Make script executable
chmod 700 get_helm.sh

# Run installation
./get_helm.sh
```

Verify installation:

```bash
helm version
```

---

### 2. Install Metrics Server

Deploy the Kubernetes Metrics Server for resource metrics:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

### 3. Add Helm Repositories

Add the required Helm chart repositories:

```bash
# Add Prometheus community charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add Grafana charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update repositories
helm repo update
```

Verify repositories:

```bash
helm repo list
```

---

### 4. Create Namespaces

Create dedicated namespaces for monitoring components:

```bash
kubectl create ns prometheus
kubectl create ns grafana
```

Verify namespaces:

```bash
kubectl get ns
```

---

### 5. Install Prometheus

Deploy Prometheus with persistent storage:

```bash
helm install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass=gp2 \
  --set server.persistentVolume.enabled=true \
  --set server.persistentVolume.storageClass=gp2
```

Verify deployment:

```bash
# Check pods
kubectl get pods -n prometheus

# Check all resources
kubectl get all -n prometheus
```

---

### 6. Install Grafana

Deploy Grafana with LoadBalancer service:

```bash
helm install grafana grafana/grafana \
  --namespace grafana \
  --set persistence.enabled=true \
  --set persistence.storageClassName=gp2 \
  --set adminPassword=root12345 \
  --set service.type=LoadBalancer
```

> ⚠️ **Security Note:** Change `adminPassword` to a strong password for production environments.

Verify deployment:

```bash
# Watch pods until ready
kubectl get pods -n grafana -w

# Check all resources
kubectl get all -n grafana
```

---

## ⚙️ Configuration

### Access Grafana

1. Get the external LoadBalancer URL:

   ```bash
   kubectl get svc -n grafana
   ```

2. Copy the **EXTERNAL-IP** (ELB DNS name) and open it in your browser.

3. Login with:

   | Field | Value |
   |-------|-------|
   | **Username** | `admin` |
   | **Password** | `root12345` *(or your custom password)* |

---

### Add Prometheus Data Source

1. Navigate to **Configuration** → **Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Enter the following URL:

   ```
   http://prometheus-server.prometheus.svc.cluster.local
   ```

5. Click **Save & Test**

---

### Import Dashboards

Navigate to **Home** → **Dashboards** → **Import** and use the following dashboard IDs:

| Dashboard ID | Name | Description |
|:------------:|------|-------------|
| `1860` | Node Exporter Full | Detailed node metrics |
| `6417` | Kubernetes Cluster (Prometheus) | Cluster overview |
| `315` | Kubernetes Cluster Monitoring | General cluster monitoring |
| `11454` | PV and PVC | Persistent volume metrics |
| `747` | Pod Metrics | Pod-level metrics |
| `14623` | K8s Overview | Kubernetes overview |
| `14584` | Argo CD | Argo CD metrics |
| `10907` | Monitor API Server | API server monitoring |

**Import Steps:**

1. Enter the Dashboard ID
2. Click **Load**
3. Select **Prometheus** as the data source
4. Click **Import**

---

## 🔍 Troubleshooting

### Seeing "N/A" in Dashboard Panels?

This typically occurs when **Node Exporter** is not configured. Node Exporter is required to collect metrics from worker nodes.

**Solution:** Deploy the Node Exporter DaemonSet:

```bash
helm install node-exporter prometheus-community/prometheus-node-exporter \
  --namespace prometheus
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Pods stuck in `Pending` | Check PVC and storage class configuration |
| LoadBalancer has no external IP | Verify cloud provider LB controller is running |
| Grafana can't connect to Prometheus | Verify the data source URL and namespace |
| Metrics not appearing | Ensure metrics-server is running properly |

---

## 🔐 Security Best Practices

### Change Default Grafana Password

Update the admin password immediately after installation:

**Option 1: Using Helm upgrade**

```bash
helm upgrade grafana grafana/grafana \
  --namespace grafana \
  --set adminPassword=YOUR_SECURE_PASSWORD
```

**Option 2: Using kubectl**

```bash
kubectl exec -it $(kubectl get pods -n grafana -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}') \
  -n grafana -- grafana-cli admin reset-admin-password YOUR_SECURE_PASSWORD
```

---

## 📊 Custom Dashboards

### Create a Custom Dashboard JSON

Save this as `custom-dashboard.json`:

```json
{
  "dashboard": {
    "title": "Custom Kubernetes Dashboard",
    "panels": [
      {
        "title": "CPU Usage by Node",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by(instance)(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "{{instance}}"
          }
        ]
      },
      {
        "title": "Memory Usage by Node",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "{{instance}}"
          }
        ]
      }
    ]
  }
}
```

---

## 🔧 Useful Commands

### Quick Status Check

```bash
# Check all monitoring components
echo "=== Prometheus ===" && kubectl get all -n prometheus
echo "=== Grafana ===" && kubectl get all -n grafana
```

### View Pod Logs

```bash
# Prometheus logs
kubectl logs -f deployment/prometheus-server -n prometheus

# Grafana logs
kubectl logs -f deployment/grafana -n grafana
```

### Get Grafana Admin Password (if forgotten)

```bash
kubectl get secret grafana -n grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

---

## 📦 Version Information

| Component | Chart Version | App Version |
|-----------|---------------|-------------|
| Prometheus | 25.x | 2.x |
| Grafana | 7.x | 10.x |
| Metrics Server | 3.x | 0.6.x |

Check current versions:

```bash
helm list -n prometheus
helm list -n grafana
```

---

## 🔄 Upgrade Guide

### Upgrade Prometheus

```bash
# Update Helm repos
helm repo update

# Upgrade Prometheus
helm upgrade prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --reuse-values
```

### Upgrade Grafana

```bash
# Upgrade Grafana
helm upgrade grafana grafana/grafana \
  --namespace grafana \
  --reuse-values
```

---

## 📚 Quick Reference

| Component | Namespace | Access |
|-----------|-----------|--------|
| Prometheus | `prometheus` | `prometheus-server.prometheus.svc.cluster.local` |
| Grafana | `grafana` | External: LoadBalancer IP |
| Metrics Server | `kube-system` | Internal cluster metrics |

---

## 🧹 Cleanup

To remove all monitoring components:

```bash
# Uninstall Helm releases
helm uninstall prometheus -n prometheus
helm uninstall grafana -n grafana
helm uninstall node-exporter -n prometheus  # If installed

# Delete namespaces
kubectl delete ns prometheus
kubectl delete ns grafana
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📞 Support

If you encounter any issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review pod logs for errors
3. Open an issue in this repository

---

## 🙏 Acknowledgments

- [Prometheus Community](https://prometheus.io/)
- [Grafana Labs](https://grafana.com/)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for the Kubernetes Community
</p>

<p align="center">
  <a href="#-kubernetes-monitoring-stack">⬆️ Back to Top</a>
</p>
