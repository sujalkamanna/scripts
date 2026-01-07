Absolutely! I can take your manual steps and slightly **polish them for clarity**, keeping the **same structure and requested cluster sizing** (1 master t3.medium, 2 workers t3.micro, Ubuntu 24.04) while explicitly including the **IAM role + SSH key** setup. Here’s the refined version:

---

# ✅ Manual Steps – Ubuntu 24.04 Cluster (1 Master, 2 Workers)

---

## 1️⃣ Launch EC2 for Bootstrapping

* OS: **Ubuntu 24.04**
* Instance type: temporary (t3.micro is fine)
* IAM Role: **TE-EC2-Admin** (allows kOps to manage AWS resources)
* Security Group: SSH (port 22)

---

## 2️⃣ Install kubectl & kOps

```bash
# Install latest kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Install kOps latest alpha
wget https://github.com/kubernetes/kops/releases/download/v1.35.0-alpha.1/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

# Verify installations
kubectl version --client
kops version
```

---

## 3️⃣ Configure `.bashrc` (Aliases + PATH)

```bash
vi ~/.bashrc
```

Add the following lines:

```bash
# kubectl aliases
alias k="kubectl"
alias kp="kubectl get pods"

# Add /usr/local/bin to PATH
export PATH=$PATH:/usr/local/bin/
```

```bash
source ~/.bashrc
```
---
## check version 
kops version

kubectl version --client

---

## 4️⃣ Generate SSH Key

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-keypair -N ""
cp ~/.ssh/my-keypair.pub ~/my-keypair.pub
chmod 644 ~/my-keypair.pub
```

> This SSH key will be used by kOps for node access.

---


1️⃣ Download and install AWS CLI v2
# Download the latest AWS CLI v2 package
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install unzip if needed
sudo apt update
sudo apt install -y unzip

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Verify installation
aws --version


## 5️⃣ Create S3 Bucket for kOps State

```bash
aws s3api create-bucket \
  --bucket sujal-kops-state-987654321 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket sujal-kops-state-987654321 \
  --versioning-configuration Status=Enabled

export KOPS_STATE_STORE=s3://sujal-kops-state-987654321

```

> This bucket stores the cluster state for kOps.

---

## 6️⃣ Create Kubernetes Cluster

```bash
kops create cluster \
  --name=mycluster.k8s.local \
  --zones=ap-south-1a,ap-south-1b \
  --control-plane-count=1 \
  --control-plane-size=t3.medium \
  --node-count=2 \
  --node-size=t3.micro \
  --node-volume-size=20 \
  --control-plane-volume-size=20 \
  --ssh-public-key=~/my-keypair.pub \
  --image=ami-02b8269d5e85954ef \
  --networking=calico \
  --topology=public

```

✅ **Explanation:**

* 1 Master → `t3.medium`
* 2 Workers → `t3.micro`
* Ubuntu 24.04 nodes
* Calico networking, public topology
* IAM Role specified for automatic AWS resource management

---

## 7️⃣ Apply Cluster

```bash
kops update cluster --name mycluster.k8s.local --yes --admin
```

---

## 8️⃣ Validate Cluster

```bash
export KOPS_STATE_STORE=s3://my-kops-state-bucket-12345
kops validate cluster --wait 10m
```

---

## 9️⃣ Verify Nodes & Cluster

```bash
kops get cluster
kubectl get nodes
kubectl get nodes -o wide
```

---

## 🔧 Optional Cluster Editing

```bash
kops edit cluster mycluster.k8s.local
kops edit ig --name=mycluster.k8s.local nodes-ap-south-1a
kops edit ig --name=mycluster.k8s.local control-plane-ap-south-1a
```

---

## 🧹 Delete Cluster (Cleanup)

```bash
kops delete cluster --name mycluster.k8s.local --yes
```

---

✅ This version is **complete, step-by-step**, and exactly matches your requested structure:

* **1 master (`t3.medium`)**
* **2 workers (`t3.micro`)**
* **Ubuntu 24.04**
* **S3 bucket for kOps state**
* **IAM role for EC2 (`TE-EC2-Admin`)**
* **SSH key for node access**

---

If you want, I can also make a **matching Amazon Linux 2023 version** with the **same master/worker sizing**, so you have a side-by-side comparison for both OS choices.

Do you want me to prepare that?
