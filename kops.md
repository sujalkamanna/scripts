# ✅ Ubuntu 24.04 kOps Cluster Script (FIXED & VERIFIED)

### (1 Control Plane: `c7i-flex.large`, 2 Workers: `t3.small`)

---

## 0️⃣ Prerequisites

* IAM Role **Trusted Entity = EC2**, **Permissions = AdministratorAccess**
* Public subnets with **Internet Gateway** in:

  * `ap-south-1a`
  * `ap-south-1b`
* Bootstrap EC2 Security Group:

  * SSH (22) → **Your IP**
  * HTTPS (443) → `0.0.0.0/0`

---

## 1️⃣ Launch Bootstrap EC2

* OS: **Ubuntu 24.04**
* Instance Type: **t3.micro**
* IAM Role: **TE-EC2-Admin**
* Security Group rules:

| Protocol | Port | Source               |
| -------- | ---- | -------------------- |
| SSH      | 22   | Your IP              |
| HTTPS    | 443  | 0.0.0.0/0            |
| HTTP     | 80   | 0.0.0.0/0 (optional) |

---

## 2️⃣ Install kubectl & kOps (STABLE)

```bash
# Switch to root
sudo -i

apt update -y
apt install -y curl wget

# kubectl (stable)
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

# kOps (LATEST STABLE)
curl -LO https://github.com/kubernetes/kops/releases/download/v1.30.0/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops

exit
```

### Verify

```bash
kubectl version --client
kops version
```

---

## 3️⃣ Configure Aliases (NON-ROOT USER)

```bash
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias kp="kubectl get pods -A"' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

---

## 4️⃣ Generate SSH Key (REQUIRED)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-keypair -N ""

chmod 600 ~/.ssh/my-keypair
chmod 644 ~/.ssh/my-keypair.pub
```

---

## 5️⃣ Install AWS CLI v2

```bash
sudo apt update
sudo apt install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install

aws --version
```

---

## 6️⃣ Create S3 Bucket for kOps State

```bash
aws s3api create-bucket \
  --bucket user-kops-state-987654321 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket user-kops-state-987654321 \
  --versioning-configuration Status=Enabled

export KOPS_STATE_STORE=s3://user-kops-state-987654321
```

(Optional but recommended)

```bash
echo 'export KOPS_STATE_STORE=s3://user-kops-state-987654321' >> ~/.bashrc
source ~/.bashrc
```

---

## 7️⃣ Create Cluster (PINNED & STABLE)

```bash
kops create cluster \
  --name=mycluster.k8s.local \
  --zones=ap-south-1a,ap-south-1b \
  --control-plane-count=1 \
  --control-plane-size=c7i-flex.large \
  --node-count=2 \
  --node-size=t3.small \
  --node-volume-size=20 \
  --control-plane-volume-size=20 \
  --ssh-public-key=~/.ssh/my-keypair.pub \
  --networking=calico \
  --topology=public \
  --dns=none \
  --kubernetes-version=1.29.4
```

---

## 8️⃣ Apply Cluster (CREATES AWS RESOURCES)

```bash
kops update cluster mycluster.k8s.local --yes --admin
```

⏳ Wait **5–10 minutes** for:

* Control plane EC2
* etcd
* Network Load Balancer

---

## 9️⃣ Validate Cluster (MANDATORY)

```bash
kops validate cluster --wait 10m
```

✅ Expected output:

```
Your cluster mycluster.k8s.local is ready
```

---

## 🔟 Verify Cluster State

```bash
kops get clusters
kops get ig

kubectl get nodes -o wide
kubectl get pods -A
```

---

## 1️⃣1️⃣ Optional: Edit Cluster / Instance Groups

```bash
kops edit cluster mycluster.k8s.local

kops edit ig nodes-ap-south-1a --name=mycluster.k8s.local
kops edit ig control-plane-ap-south-1a --name=mycluster.k8s.local
```

Apply changes:

```bash
kops update cluster --yes
```

---

## 1️⃣2️⃣ Cleanup (DESTROY EVERYTHING)

```bash
kops delete cluster --name mycluster.k8s.local --yes

aws s3 rb s3://user-kops-state-987654321 --force

kops get clusters
# cluster should NOT appear
```

---
