# Kubernetes HPA (Horizontal Pod Autoscaler) Setup Guide

---

## Table of Contents

1. Overview
2. Prerequisites
3. Enable Metrics Server
4. Deploy Sample Application
5. Create Service
6. Configure HPA
7. Apply HPA Manifest
8. Test Autoscaling
9. Verify Scaling Behavior
10. Useful Commands
11. Troubleshooting
12. Additional Resources
13. Official Documentation
14. Disclaimer & Attribution
15. Conclusion

---

# Overview

**Horizontal Pod Autoscaler (HPA)** automatically scales the number of pods in a Kubernetes deployment based on CPU or memory usage.

### What HPA does:

* Scales pods UP when load increases
* Scales pods DOWN when load decreases
* Maintains application performance automatically

---

# Prerequisites

Ensure:

* Kubernetes cluster is running
* `kubectl` configured
* Metrics server installed
* At least 1 deployment running

```bash id="hpa1"
kubectl get nodes
```

---

# Enable Metrics Server

HPA requires metrics server.

## Install Metrics Server

```bash id="hpa2"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## Patch Metrics Server (if needed)

For cloud / local clusters:

```bash id="hpa3"
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["--kubelet-insecure-tls"]}]'
```

---

## Verify Metrics Server

```bash id="hpa4"
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
```

---

# Deploy Sample Application

## Create Deployment Manifest

```bash id="hpa5"
nano app-deployment.yaml
```

---

## Deployment YAML

```yaml id="hpa6"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-demo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hpa-demo
  template:
    metadata:
      labels:
        app: hpa-demo
    spec:
      containers:
      - name: hpa-demo
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

---

## Apply Deployment

```bash id="hpa7"
kubectl apply -f app-deployment.yaml
```

---

# Create Service

```bash id="hpa8"
nano app-service.yaml
```

---

## Service YAML

```yaml id="hpa9"
apiVersion: v1
kind: Service
metadata:
  name: hpa-demo-service
spec:
  selector:
    app: hpa-demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

---

## Apply Service

```bash id="hpa10"
kubectl apply -f app-service.yaml
```

---

# Configure HPA

## Create HPA Manifest

```bash id="hpa11"
nano hpa.yaml
```

---

## HPA YAML Configuration

```yaml id="hpa12"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

---

## Apply HPA

```bash id="hpa13"
kubectl apply -f hpa.yaml
```

---

# Test Autoscaling

## Check HPA Status

```bash id="hpa14"
kubectl get hpa
```

---

## Generate Load

Run busy load pod:

```bash id="hpa15"
kubectl run -it load-generator --image=busybox /bin/sh
```

Inside pod:

```bash id="hpa16"
while true; do wget -q -O- http://hpa-demo-service; done
```

---

# Verify Scaling Behavior

## Watch HPA

```bash id="hpa17"
kubectl get hpa -w
```

## Check Pods

```bash id="hpa18"
kubectl get pods -l app=hpa-demo
```

Expected:

* Pods increase when CPU increases
* Pods decrease when load reduces

---

# Useful Commands

```bash id="hpa19"
kubectl describe hpa hpa-demo
kubectl top pods
kubectl top nodes
kubectl get deployment
```

---

# Troubleshooting

## HPA not scaling

Check metrics:

```bash id="hpa20"
kubectl top pods
```

---

## Metrics server not working

```bash id="hpa21"
kubectl logs -n kube-system deployment/metrics-server
```

---

## No CPU metrics

Ensure resources are defined in deployment:

* requests.cpu must be set

---

# Additional Resources

| Resource            | URL                                                                        |
| ------------------- | -------------------------------------------------------------------------- |
| Kubernetes HPA Docs | https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| Metrics Server      | https://github.com/kubernetes-sigs/metrics-server                          |
| Kubernetes Docs     | https://kubernetes.io/docs                                                 |

---

# 📎 Official Documentation

* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
* https://github.com/kubernetes-sigs/metrics-server

---

# 📎 Disclaimer & Attribution

This guide is for DevOps and Kubernetes learning purposes.

HPA is a Kubernetes autoscaling feature used to automatically adjust workload replicas based on metrics.

All trademarks belong to their respective owners.

---

# 🎉 Conclusion

```text id="hpaflow"
Metrics Server
+
CPU Metrics
+
HPA Controller
+
Deployment
+
Pods
+
Scaling Up/Down
```

Kubernetes HPA enables automatic scaling of applications based on resource usage, improving performance, reliability, and cost efficiency in cloud-native environments.

---

```md id="hpameta"
**Last Updated:** 2026  
**Tool:** Kubernetes HPA  
**Version:** autoscaling/v2  
**Platform:** Kubernetes  
**License:** CNCF Open Source  

For official docs:
https://kubernetes.io/
```