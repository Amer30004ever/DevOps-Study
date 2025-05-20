# <img src="https://cdn-icons-png.flaticon.com/512/6125/6125000.png" width="30"> ArgoCD Kubernetes Deployment Guide

This guide provides step-by-step instructions for deploying ArgoCD, a declarative GitOps continuous delivery tool, in your Kubernetes cluster.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Accessing ArgoCD](#accessing-argocd)
4. [Login Credentials](#login-credentials)
5. [Security Considerations](#security-considerations)

## <img src="https://cdn-icons-png.flaticon.com/512/1045/1045911.png" width="25"> Prerequisites
- Kubernetes cluster (Minikube or production-ready)
- `kubectl` configured with cluster admin privileges
- Network access to GitHub (for manifest download)

## <img src="https://cdn-icons-png.flaticon.com/512/888/888928.png" width="25"> Installation

1. Create ArgoCD namespace:
```bash
kubectl create namespace argocd
```

2. Apply official ArgoCD manifests:
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

3. Wait for pods to initialize:
```bash
sleep 100  # Wait approximately 1-2 minutes for all components to be ready
```

## <img src="https://cdn-icons-png.flaticon.com/512/1006/1006771.png" width="25"> Accessing ArgoCD

### Option 1: Local Access (Inside VM)
```bash
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```
Access at: `https://localhost:8080`

### Option 2: External Access (Minikube)
```bash
minikube service argocd-server -n argocd
```

Verify services are running:
```bash
kubectl get svc -n argocd
```

## <img src="https://cdn-icons-png.flaticon.com/512/3064/3064155.png" width="25"> Login Credentials

1. Retrieve initial admin password:
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode && echo
```

2. Login with:
- Username: `admin`
- Password: [output from above command]

## <img src="https://cdn-icons-png.flaticon.com/512/2889/2889676.png" width="25"> Security Considerations

1. **Change default password** immediately after first login
2. **Delete initial secret** after password change:
```bash
kubectl delete secret argocd-initial-admin-secret -n argocd
```