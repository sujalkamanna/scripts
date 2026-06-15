# Kubernetes Cluster Setup on Ubuntu 24.04 / 26.04 (Master + Worker Nodes)

## Overview

This repository provides automated scripts to deploy a Kubernetes cluster using **kubeadm**, **containerd**, and **Flannel CNI**.

The cluster consists of:

* 1 Control Plane (Master) Node
* 1 or more Worker Nodes

The scripts automate:

* System updates
* Swap disabling
* Kernel and networking configuration
* Containerd installation and configuration
* Kubernetes component installation (kubeadm, kubelet, kubectl)
* Control Plane initialization
* Flannel CNI deployment
* Worker node cluster joining

---

## Kubernetes Version

| Component         | Version                     |
| ----------------- | --------------------------- |
| Kubernetes        | 1.33.x                      |
| Container Runtime | containerd                  |
| CNI               | Flannel                     |
| OS                | Ubuntu 24.04 / Ubuntu 26.04 |

---

## Prerequisites

* Ubuntu 24.04 LTS or Ubuntu 26.04 LTS
* Minimum 2 vCPU and 4 GB RAM per node
* Root or sudo access
* Internet connectivity
* Security Group or firewall rules allowing Kubernetes traffic

### Required Ports

#### Control Plane

| Port      | Purpose               |
| --------- | --------------------- |
| 6443      | Kubernetes API Server |
| 2379-2380 | etcd                  |
| 10250     | Kubelet               |
| 10257     | Controller Manager    |
| 10259     | Scheduler             |

#### Worker Nodes

| Port        | Purpose           |
| ----------- | ----------------- |
| 10250       | Kubelet           |
| 30000-32767 | NodePort Services |

---

## Repository Files

| File                | Description                                   |
| ------------------- | --------------------------------------------- |
| k8-common-script.sh | Common setup for all nodes                    |
| k8-master-script.sh | Initializes control plane and deploys Flannel |
| k8-slave-script.sh  | Joins worker node to cluster                  |

---

## Download Scripts

```bash
curl -LO https://raw.githubusercontent.com/sujalkamanna/scripts/refs/heads/main/k8-common-script.sh
```
```bash
curl -LO https://raw.githubusercontent.com/sujalkamanna/scripts/refs/heads/main/k8-master-script.sh
```
```bash
curl -LO https://raw.githubusercontent.com/sujalkamanna/scripts/refs/heads/main/k8-slave-script.sh
```

Make them executable:

```bash
chmod +x *.sh
```

---

# Master Node Setup

### Set Hostname

```bash
sudo hostnamectl set-hostname master
```

Reconnect to the server or open a new shell:

```bash
exec bash
```

### Run Common Setup

```bash
./k8-common-script.sh
```

### Initialize Control Plane

```bash
./k8-master-script.sh
```

The script will:

* Initialize Kubernetes
* Configure kubectl
* Deploy Flannel CNI
* Display the worker join command

Save the generated join command.

Example:

```bash
kubeadm join 10.0.0.10:6443 \
--token abcdef.1234567890123456 \
--discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxx
```

---

# Worker Node Setup

### Set Hostname

```bash
sudo hostnamectl set-hostname worker-1
```

Reconnect to the server or open a new shell:

```bash
exec bash
```

### Run Common Setup

```bash
./k8-common-script.sh
```

### Join Cluster

```bash
./k8-slave-script.sh
```

Paste the join command generated on the master node when prompted.

Example:

```bash
kubeadm join 10.0.0.10:6443 \
--token abcdef.1234567890123456 \
--discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxx
```

---

# Verification

Run on the master node:

```bash
kubectl get nodes
```

Expected:

```text
NAME       STATUS   ROLES           AGE   VERSION
master     Ready    control-plane   5m    v1.33.x
worker-1   Ready    <none>          2m    v1.33.x
```

---

## Verify System Pods

```bash
kubectl get pods -A
```

Expected:

```text
NAMESPACE     NAME                               STATUS
kube-system   coredns-xxxxx                      Running
kube-system   kube-flannel-ds-xxxxx              Running
kube-system   kube-proxy-xxxxx                   Running
```

---

# Deploy a Test Application

Create an NGINX pod:

```bash
kubectl run nginx \
--image=nginx:stable \
--restart=Never
```

Expose it using NodePort:

```bash
kubectl expose pod nginx \
--type=NodePort \
--port=80
```

View the service:

```bash
kubectl get svc
```

Example:

```text
NAME    TYPE       CLUSTER-IP      PORT(S)
nginx   NodePort   10.96.120.20    80:31234/TCP
```

Access:

```text
http://<worker-public-ip>:31234
```

---

# Useful Commands

Check cluster status:

```bash
kubectl get nodes -o wide
```

View all pods:

```bash
kubectl get pods -A
```

View services:

```bash
kubectl get svc -A
```

View cluster information:

```bash
kubectl cluster-info
```

---

# Optional Kubectl Alias

```bash
echo 'alias kc=kubectl' >> ~/.bashrc
source ~/.bashrc
```

Usage:

```bash
kc get nodes
```

---

# Cleanup Cluster

Reset a node:

```bash
sudo kubeadm reset -f
```

Remove Kubernetes configuration:

```bash
rm -rf ~/.kube
```

---

# Notes

* Uses containerd as the container runtime.
* Uses Flannel CNI with pod CIDR 10.244.0.0/16.
* Supports Ubuntu 24.04 LTS and Ubuntu 26.04 LTS.
* Tested with Kubernetes 1.33.x.
* Scripts are intended for learning, homelabs, cloud labs, and DevOps/SRE practice environments.