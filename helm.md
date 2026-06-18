# Kubernetes Helm Installation Guide (Ubuntu 24.04 + Kubernetes Cluster)

---

## Table of Contents

1. Overview
2. Prerequisites
3. Install Helm
4. Verify Installation
5. Add Helm Repositories
6. Install Sample Application
7. Helm Basic Commands
8. Uninstall Application
9. Troubleshooting
10. Additional Resources
11. Official Documentation
12. Disclaimer & Attribution
13. Conclusion

---

# Overview

Helm is a **package manager for Kubernetes** that simplifies deploying, managing, and upgrading applications using reusable templates called **charts**.

With Helm, you can:

* Deploy applications in Kubernetes easily
* Manage configurations using values files
* Upgrade or rollback releases
* Use prebuilt charts from public repositories

---

# Prerequisites

Ensure you have:

* Kubernetes cluster (Minikube / Kops / EKS / Kind)
* `kubectl` installed and configured
* Cluster access verified

Verify Kubernetes:

```bash id="k8v1"
kubectl get nodes
```

Expected:

* Nodes should be in `Ready` state

---

# Install Helm

## Step 1: Download Helm Script

```bash id="helm1"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

## Step 2: Verify Installation

```bash id="helm2"
helm version
```

Expected output:

```text id="helmver"
version.BuildInfo{Version:"v3.x.x"}
```

---

# Add Helm Repositories

## Add Stable Repository

```bash id="helm3"
helm repo add stable https://charts.helm.sh/stable
```

## Add Bitnami Repository (Recommended)

```bash id="helm4"
helm repo add bitnami https://charts.bitnami.com/bitnami
```

## Update Repositories

```bash id="helm5"
helm repo update
```

---

# Install Sample Application (Nginx)

## Step 1: Search Chart

```bash id="helm6"
helm search repo nginx
```

---

## Step 2: Install Nginx

```bash id="helm7"
helm install my-nginx bitnami/nginx
```

---

## Step 3: Check Deployment

```bash id="helm8"
kubectl get pods
kubectl get svc
```

---

## Step 4: Access Application

If LoadBalancer is used:

```bash id="helm9"
kubectl get svc my-nginx
```

Open browser:

```text id="helm10"
http://<EXTERNAL-IP>
```

---

# Helm Basic Commands

## List Releases

```bash id="helm11"
helm list
```

## Upgrade Release

```bash id="helm12"
helm upgrade my-nginx bitnami/nginx
```

## Rollback Release

```bash id="helm13"
helm rollback my-nginx 1
```

## Get Release Details

```bash id="helm14"
helm status my-nginx
```

---

# Uninstall Application

```bash id="helm15"
helm uninstall my-nginx
```

Verify removal:

```bash id="helm16"
helm list
kubectl get pods
```

---

# Troubleshooting

## Issue: Helm command not found

```bash id="helm17"
which helm
```

Reinstall Helm if missing.

---

## Issue: Chart not found

```bash id="helm18"
helm repo update
helm search repo <chart-name>
```

---

## Issue: Pods not running

```bash id="helm19"
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

---

# Additional Resources

| Resource        | URL                        |
| --------------- | -------------------------- |
| Helm Docs       | https://helm.sh/docs       |
| Helm Charts     | https://artifacthub.io     |
| Kubernetes Docs | https://kubernetes.io/docs |
| Bitnami Charts  | https://charts.bitnami.com |

---

# 📎 Official Documentation

* https://helm.sh/docs/
* https://kubernetes.io/docs/home/
* https://artifacthub.io/

---

# 📎 Disclaimer & Attribution

This document is an unofficial educational guide created for DevOps learning, Kubernetes deployment practice, and CI/CD workflow understanding.

Helm is a CNCF project used for Kubernetes application packaging and deployment automation.

All trademarks belong to their respective owners.

---

# 🎉 Conclusion

```text id="helmflow"
Helm CLI
+
Charts
+
Repositories
+
Values.yaml
+
Kubernetes API
+
Deployments
+
Services
+
Pods
```

Helm simplifies Kubernetes application deployment by managing complex YAML configurations through reusable charts, enabling faster and more reliable application delivery in cloud-native environments.

---

```md id="helmmeta"
**Last Updated:** 2026  
**Tool:** Helm  
**Platform:** Kubernetes  
**Version:** Helm 3.x  
**License:** CNCF Open Source  

For official docs:
https://helm.sh/docs/
```