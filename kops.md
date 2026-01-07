Perfect! I’ve rewritten your **complete Ubuntu 24.04 kOps setup script** so that it addresses all the issues you faced. This version uses:

* **AMI ID for Ubuntu 24.04**
* **Consistent `KOPS_STATE_STORE`**
* **Correct security group rules** for the bootstrap instance
* **IAM role reminder**
* **Public subnets with internet access**

Here’s the ready-to-run version:

---

# ✅ Ubuntu 24.04 kOps Cluster Script (1 Master t3.medium, 2 Workers t3.micro)

---

## 0️⃣ Prerequisites

* Make sure your **IAM Role** (`TE-EC2-Admin`) exists with permissions for: EC2, S3, VPC, ELB, IAM, Route53.
* You have a **public subnet with internet access** in `ap-south-1a` and `ap-south-1b`.
* Security group for bootstrap instance allows **SSH from your IP**.

---

## 1️⃣ Launch Bootstrap EC2

* OS: Ubuntu 24.04
* Instance type: t3.micro
* IAM Role: TE-EC2-Admin
* SG inbound rules:

| Protocol | Port | Source               |
| -------- | ---- | -------------------- |
| SSH      | 22   | Your IP              |
| HTTPS    | 443  | 0.0.0.0/0            |
| HTTP     | 80   | 0.0.0.0/0 (optional) |

---

## 2️⃣ Install kubectl & kOps

```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# kOps
wget https://github.com/kubernetes/kops/releases/download/v1.35.0-alpha.1/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

# Verify
kubectl version --client
kops version
```

---

## 3️⃣ Configure Aliases

```bash
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias kp="kubectl get pods"' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/bin/' >> ~/.bashrc
source ~/.bashrc
```

---

## 4️⃣ Generate SSH Key

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-keypair -N ""
chmod 644 ~/.ssh/my-keypair.pub
```

> This key will be used by kOps to SSH into nodes.

---

## 5️⃣ Install AWS CLI v2

```bash
sudo apt update
sudo apt install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

---

## 6️⃣ Create S3 Bucket for kOps State

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

---

## 7️⃣ Create Cluster

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
  --ssh-public-key=~/.ssh/my-keypair.pub \
  --image=ami-02b8269d5e85954ef \
  --networking=calico \
  --topology=public \
  --yes
```

---

## 8️⃣ Apply Cluster

```bash
kops update cluster --name mycluster.k8s.local --yes --admin
```

> Wait **5–10 minutes** for Network Load Balancer and master creation.

---

## 9️⃣ Validate Cluster

```bash
export KOPS_STATE_STORE=s3://sujal-kops-state-987654321
kops validate cluster --wait 10m
```

> If you see `i/o timeout`, check **SG rules, public subnet, internet access**, and retry.

---

## 🔟 Verify Nodes & Pods

```bash
kops get cluster
kops get ig
kubectl get nodes -o wide
kubectl get pods -A
```

---

## 1️⃣1️⃣ Optional: Edit Cluster

```bash
kops edit cluster mycluster.k8s.local
kops edit ig --name=mycluster.k8s.local nodes-ap-south-1a
kops edit ig --name=mycluster.k8s.local control-plane-ap-south-1a
```

---

## 1️⃣2️⃣ Cleanup

```bash
kops delete cluster --name mycluster.k8s.local --yes
aws s3 rb s3://sujal-kops-state-987654321 --force
```

---

✅ This script **should work without previous errors**:

* Uses **AMI ID for Ubuntu 24.04**
* Uses **consistent S3 bucket**
* Includes **IAM role** and **SSH key**
* Correct **SG inbound rules**
* Ensures **public subnet with internet access** for master nodes

---

If you want, I can also prepare a **fully automated one-liner version** that installs everything and creates the cluster in **one shot**, so you don’t have to run each step manually.

Do you want me to do that next?
