# 🚀 Setup Argo CD on Kubernetes

---

## 🛠 1) Install Helm (Latest Version)

Download and run the official Helm install script:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
````

This downloads and runs the official Helm install script. ([Argo Project][1])

---

## ✅ 2) Verify Helm Installation

```bash
helm version
```

---

## 📥 3) Add the Argo‑Helm Repository

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

This adds the official Argo‑Helm chart repository. ([Argo Project][1])

---

## 🧱 4) Install Argo CD Using Helm

```bash
kubectl create namespace argons
helm install argocd argo/argo-cd --namespace argons
kubectl get all -n argons
```

This installs Argo CD into the `argons` namespace. ([Argo Project][1])

---

## 🌐 5) Expose the Argo CD Server

Make the Argo CD server service externally reachable:

```bash
kubectl patch svc argocd-server -n argons -p '{"spec": { "type": "LoadBalancer" }}'
kubectl get all -n argons
```

This changes the Argo CD server service type to `LoadBalancer` so you can access it externally. ([Argo CD][2])

---

## 🌐 6) Argo CD Dashboard

Once the LoadBalancer external IP is ready (or NodePort/ingress configured), open the Argo CD UI in your browser at:

```
http://<EXTERNAL-IP>
```

If LoadBalancer isn’t available yet, you can also use **port‑forward**:

```bash
kubectl port-forward svc/argocd-server -n argons 8080:443
```

Then open in a browser:

```
https://localhost:8080
```

---

## 🔐 7) Login Credentials

### Username

```
admin
```

### Password

Retrieve the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

This decodes the auto‑generated admin password stored in the secret. ([Argo CD][3])

Once logged in, it’s recommended to **change the default admin password** for security.

---

## 📝 Notes

* The initial `admin` password is stored in the `argocd-initial-admin-secret` secret and can be decoded as shown above. ([Argo CD][3])
* The Argo CD Helm chart installs all necessary components and CRDs if needed. ([Argo Project][1])

---

```

If you want, I can also add a section for **installing the Argo CD CLI** and logging in via the CLI!
::contentReference[oaicite:7]{index=7}
```

[1]: https://argoproj.github.io/argo-helm/?utm_source=chatgpt.com "Argo Helm Charts | argo-helm"
[2]: https://kostis-argo-cd.readthedocs.io/en/refresh-docs/getting_started/first_steps/?utm_source=chatgpt.com "First steps - Argo CD - Declarative GitOps CD for Kubernetes"
[3]: https://argo-cd.readthedocs.io/en/release-2.0/getting_started/?utm_source=chatgpt.com "Getting Started - Argo CD - Declarative GitOps CD for Kubernetes"
