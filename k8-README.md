---

# **Kubernetes Cluster Setup on Ubuntu 24.04 (Master + Worker Nodes)**

## Overview

This guide provides **automated scripts** to set up a Kubernetes cluster with **containerd** as the container runtime. The cluster includes:

* **1 Master Node**
* **1 or more Worker Nodes**

All nodes are assumed to be **Ubuntu 24.04 EC2 instances**, with necessary ports open in security groups.

The scripts handle:

* System updates and kernel configuration
* Swap disabling
* Containerd installation and configuration
* Kubernetes (kubeadm, kubelet, kubectl) installation
* Master initialization and Flannel CNI deployment
* Worker node joining

---

## **Prerequisites**

* Ubuntu 24.04 on all nodes
* EC2 instance type (e.g., t2.medium)
* All inbound traffic allowed in Security Group (or proper Kubernetes ports)
* Root or sudo access on all nodes
* Swap disabled (handled by scripts)

---

## **Files**

| File               | Description                                                                       |
| ------------------ | --------------------------------------------------------------------------------- |
| `k8-common-script` | Installs prerequisites, containerd, and Kubernetes components on all nodes        |
| `k8-master-script` | Initializes the master node, deploys Flannel CNI, prints join command for workers |
| `k8-slave-script`  | Joins worker node to the cluster using join command from master                   |

---

## **Setup Instructions**

### **1. Master Node**

1. Set hostname:

```bash
sudo hostnamectl set-hostname master
```

2. Make scripts executable:

```bash
chmod +x k8-common-script k8-master-script
```

3. Run common setup:

```bash
./k8-common-script
```

4. Run master setup:

```bash
./k8-master-script
```

5. **Copy the join command** displayed at the end — needed for worker nodes.

---

### **2. Worker Node(s)**

1. Set hostname:

```bash
sudo hostnamectl set-hostname slave
```

2. Make scripts executable:

```bash
chmod +x k8-common-script k8-slave-script
```

3. Run common setup:

```bash
./k8-common-script
```

4. Run worker setup:

```bash
./k8-slave-script
```

* If using the **interactive version**, paste the join command from the master when prompted.
* If using the **hardcoded version**, update `<MASTER-IP>`, `<TOKEN>`, and `<HASH>` in `k8-slave-script` before running.

---

## **Verification**

On the master node:

1. Check node status:

```bash
kubectl get nodes
```

Expected output:

```
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   Xm    v1.30.x
slave    Ready    <none>          Xm    v1.30.x
```

2. Check system pods:

```bash
kubectl get pods -A
```

Expected pods:

```
kube-system
NAME                       READY   STATUS    RESTARTS   AGE
coredns-xxxxx               1/1     Running   0          Xm
kube-flannel-ds-xxxxx       1/1     Running   0          Xm
kube-proxy-xxxxx            1/1     Running   0          Xm
```

---

## **Deploy a Test Pod**

1. Deploy nginx:

```bash
kubectl run my-nginx --image=nginx:slim
```

2. Expose it (NodePort):

```bash
kubectl expose pod my-nginx --type=NodePort --port=80
kubectl get svc
```

3. Access from browser:

```
http://<worker-node-ip>:<NodePort>
```

---

## **Optional**

* Enable `kubectl` alias:

```bash
echo "alias kc=kubectl" >> ~/.bashrc
source ~/.bashrc
```

* Verify DNS from worker pods:

```bash
kubectl run -it --rm busybox --image=busybox --restart=Never -- sh
# Inside pod:
wget -qO- http://my-nginx:80
```

---

## **Notes**

* Scripts assume Ubuntu 24.04 and containerd.
* Make sure swap is disabled (handled in scripts).
* Flannel CNI is used (pod network CIDR: `10.244.0.0/16`).
* Worker nodes cannot resolve service names from host — test from pods or NodePort.

---

This README ensures anyone can reproduce your **Master + Worker Kubernetes cluster** on EC2 with minimal manual steps.

---
