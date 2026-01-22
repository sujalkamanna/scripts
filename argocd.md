# 🚀 Argo CD Installation Guide for Kubernetes

Complete step-by-step guide to install and configure Argo CD on your Kubernetes cluster using Helm.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- ✅ **Kubernetes cluster** (v1.24+) running and accessible
- ✅ **kubectl** configured and connected to your cluster
- ✅ **Cluster admin permissions**
- ✅ **Internet connectivity** for downloading Helm charts

Verify your cluster connection:
```bash
kubectl cluster-info
kubectl get nodes
```

---

## 🛠️ Step 1: Install Helm (Latest Version)

Download and install the official Helm 3 client:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

**What this does:** Downloads and executes the official Helm installation script from the Helm GitHub repository.

### ✅ Verify Helm Installation

```bash
helm version
```

**Expected output:**
```
version.BuildInfo{Version:"v3.x.x", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.x"}
```

---

## 📥 Step 2: Add the Argo Helm Repository

Add the official Argo Project Helm chart repository:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

**Verify the repository was added:**
```bash
helm search repo argo-cd
```

**Expected output:**
```
NAME              CHART VERSION  APP VERSION  DESCRIPTION
argo/argo-cd      5.x.x          v2.x.x       A Helm chart for Argo CD...
```

---

## 🧱 Step 3: Install Argo CD Using Helm

Create a dedicated namespace and install Argo CD:

```bash
# Create namespace
kubectl create namespace argocd

# Install Argo CD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 5.51.6

# Verify installation
kubectl get all -n argocd
```

> **Note:** Replace namespace `argocd` with your preferred name. The guide uses `argocd` as the standard namespace name (not `argons`).

### 🔍 Check Installation Status

Wait for all pods to be in `Running` state:

```bash
kubectl get pods -n argocd -w
```

**Expected output:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          2m
argocd-dex-server-xxx                 1/1     Running   0          2m
argocd-redis-xxx                      1/1     Running   0          2m
argocd-repo-server-xxx                1/1     Running   0          2m
argocd-server-xxx                     1/1     Running   0          2m
```

---

## 🌐 Step 4: Expose the Argo CD Server

Choose one of the following methods to access the Argo CD UI:

### **Option A: LoadBalancer (Recommended for Cloud)**

Patch the Argo CD server service to type `LoadBalancer`:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Get the external IP:
```bash
kubectl get svc argocd-server -n argocd
```

**Wait for EXTERNAL-IP:**
```
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)
argocd-server   LoadBalancer   10.100.200.x    35.x.x.x        80:xxxxx/TCP,443:xxxxx/TCP
```

Access Argo CD at: `https://<EXTERNAL-IP>`

---

### **Option B: Port Forwarding (For Local/Testing)**

Forward the service to your local machine:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access Argo CD at: `https://localhost:8080`

> ⚠️ **Note:** You'll see a certificate warning because Argo CD uses a self-signed certificate by default. This is safe to proceed in development.

---

### **Option C: Ingress (Recommended for Production)**

Create an Ingress resource with TLS:

```yaml
# argocd-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
  tls:
  - hosts:
    - argocd.yourdomain.com
    secretName: argocd-server-tls
```

Apply the Ingress:
```bash
kubectl apply -f argocd-ingress.yaml
```

---

## 🔐 Step 5: Get Login Credentials

### Username
```
admin
```

### Password

Retrieve the auto-generated admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

**Example output:**
```
mQ7xK9vN2pL5rT8w
```

> 💡 **Security Tip:** This password is randomly generated during installation. Store it securely!

---

## 🖥️ Step 6: Access the Argo CD Dashboard

1. **Open your browser** and navigate to:
   - LoadBalancer: `https://<EXTERNAL-IP>`
   - Port-forward: `https://localhost:8080`
   - Ingress: `https://argocd.yourdomain.com`

2. **Accept the certificate warning** (self-signed cert)

3. **Login with:**
   - Username: `admin`
   - Password: (from Step 5)

![Argo CD Login Screen](https://argo-cd.readthedocs.io/en/stable/assets/login.png)

---

## 🔧 Step 7: Install Argo CD CLI (Optional but Recommended)

The CLI provides powerful command-line access to Argo CD:

### **Linux/macOS:**
```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

### **macOS (Homebrew):**
```bash
brew install argocd
```

### **Windows (PowerShell):**
```powershell
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
$url = "https://github.com/argoproj/argo-cd/releases/download/" + $version + "/argocd-windows-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile $env:USERPROFILE\bin\argocd.exe
```

### **Verify CLI Installation:**
```bash
argocd version --client
```

---

## 🔑 Step 8: Login via CLI

### Using Port-Forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
argocd login localhost:8080
```

### Using External IP/Domain:
```bash
argocd login <EXTERNAL-IP-or-DOMAIN>
```

**Enter credentials when prompted:**
- Username: `admin`
- Password: (from Step 5)

**Login with password directly:**
```bash
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password $ARGO_PWD --insecure
```

---

## 🔒 Step 9: Change Default Admin Password (Recommended)

### Via CLI:
```bash
argocd account update-password
```

### Via UI:
1. Click on **User Info** (top-left profile icon)
2. Select **Update Password**
3. Enter current and new password
4. Click **Save**

---

## 🧹 Step 10: Delete Initial Secret (After Password Change)

Once you've changed the password, remove the initial secret:

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

---

## ⚙️ Advanced Configuration (Optional)

### Enable High Availability (HA)

Install Argo CD with HA mode:

```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set redis-ha.enabled=true \
  --set controller.replicas=3 \
  --set server.replicas=3 \
  --set repoServer.replicas=3
```

---

### Custom Values File

Create `argocd-values.yaml`:

```yaml
server:
  replicas: 2
  service:
    type: LoadBalancer
  
configs:
  params:
    server.insecure: true  # Use when behind HTTPS proxy
  
repoServer:
  replicas: 2

controller:
  replicas: 2
```

Install with custom values:
```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  -f argocd-values.yaml
```

---

## 🧪 Verification & Testing

### Check All Resources:
```bash
kubectl get all,cm,secret -n argocd
```

### View Logs:
```bash
kubectl logs -n argocd deployment/argocd-server -f
```

### Health Check:
```bash
argocd version
```

**Expected output:**
```
argocd: v2.x.x+xxxxx
  BuildDate: 2024-xx-xx
  GitCommit: xxxxx
  GoVersion: go1.21
argocd-server: v2.x.x+xxxxx
```

---

## 🐛 Troubleshooting

### Issue: Pods Not Starting

```bash
kubectl describe pod -n argocd <pod-name>
kubectl logs -n argocd <pod-name>
```

### Issue: Can't Access UI

```bash
# Check service status
kubectl get svc argocd-server -n argocd

# Check if port-forward is working
kubectl port-forward svc/argocd-server -n argocd 8080:443
curl -k https://localhost:8080
```

### Issue: Forgot Password

Reset admin password:
```bash
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "'$(htpasswd -nbBC 10 "" NewPassword123 | tr -d ':\n' | sed 's/$2y/$2a/')'"}}'
```

---

## 📚 Next Steps

Now that Argo CD is installed:

1. ✅ **Create your first application** → [Deploy Example Voting App](#)
2. ✅ **Configure Git repositories** → [Repository Setup Guide](#)
3. ✅ **Set up SSO/RBAC** → [Security Configuration](#)
4. ✅ **Enable notifications** → [Notifications Setup](#)

---

## 📖 Additional Resources

- 📘 [Official Argo CD Documentation](https://argo-cd.readthedocs.io/)
- 🎥 [Argo CD Tutorial Videos](https://www.youtube.com/c/ArgoProj)
- 💬 [Argo CD Slack Community](https://argoproj.github.io/community/join-slack)
- 🐙 [Argo CD GitHub Repository](https://github.com/argoproj/argo-cd)
- 📦 [Argo Helm Charts](https://github.com/argoproj/argo-helm)

---

## 📝 Quick Reference Commands

```bash
# Argo CD Server
kubectl get svc argocd-server -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# CLI login
argocd login localhost:8080

# List applications
argocd app list

# Sync application
argocd app sync <app-name>

# Check Argo CD status
kubectl get pods -n argocd
```

---

**🎉 Congratulations! Argo CD is now installed and ready to use!**

---

**Questions or issues?** Open an issue on GitHub or join the [Argo CD Slack](https://argoproj.github.io/community/join-slack).
