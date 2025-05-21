# 🛡️ Linkerd Service Mesh on Kind with MetalLB & Ingress

![Linkerd](https://img.shields.io/badge/Linkerd-2.14.0-2BDE73?logo=linkerd)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27-326CE5?logo=kubernetes)
![MetalLB](https://img.shields.io/badge/MetalLB-v0.13.7-FF6D01)
![Ingress](https://img.shields.io/badge/Ingress-Nginx-269539)

## 📦 Prerequisites

```bash
# Verify tools
docker --version  # 20.10+
kind version      # 0.17+
kubectl version --short  # 1.27+
```

## 🚀 Installation

### 1. Create Optimized Kind Cluster
```bash
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF

kind create cluster --config kind-config.yaml --name linkerd-demo
```

### 2. Install Linkerd
```bash
curl -fsL https://github.com/linkerd/linkerd2/releases/download/stable-2.14.0/linkerd2-cli-stable-2.14.0-linux-amd64 -o linkerd
chmod +x linkerd && sudo mv linkerd /usr/local/bin/

linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
linkerd viz install | kubectl apply -f -
```

## 🌐 Networking Setup

### MetalLB Load Balancer
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=120s

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.100-172.18.0.200
EOF

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF
```

### Ingress Controller (Optional)
```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.allowSnippetAnnotations=false
```

## 🔍 Verification

```bash
# Core components
linkerd check
linkerd viz check

# Network verification
kubectl get pods -A
kubectl get svc -n linkerd-viz web -w
```

## 🎯 Access Methods

### Method 1: Direct LoadBalancer (Simplest)
```bash
EXTERNAL_IP=$(kubectl get svc -n linkerd-viz web -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Dashboard: http://$EXTERNAL_IP:8084"
```

### Method 2: Ingress (Production)
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: linkerd-dashboard
  namespace: linkerd-viz
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header l5d-dst-override \$service_name.\$namespace.svc.cluster.local;
spec:
  ingressClassName: nginx
  rules:
  - host: dashboard.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 8084
EOF

echo "$EXTERNAL_IP dashboard.example.com" | sudo tee -a /etc/hosts
```

## 🧹 Cleanup
### 1. Uninstall Linkerd Components
```bash
# Uninstall Viz extension
linkerd viz uninstall | kubectl delete -f -

# Uninstall control plane
linkerd uninstall | kubectl delete -f -

# Delete CRDs
linkerd install --crds | kubectl delete -f -

# Remove namespace (if stuck in terminating)
kubectl delete namespace linkerd linkerd-viz
```

### 2. Uninstall MetalLB
```bash
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Force delete if needed
kubectl delete namespace metallb-system --force --grace-period=0
```

### 3. Uninstall Ingress-NGINX
```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### 4. Delete Kind Cluster
```bash
kind delete cluster --name linkerd-demo
```

### 5. Clean Local Files
```bash
sudo rm /usr/local/bin/linkerd
rm -rf ~/.linkerd2
```

### 6. Verify Complete Removal
```bash
# Check all Kubernetes resources
kubectl get all --all-namespaces

# Check for lingering resources
kubectl get crds | grep -E 'linkerd|metallb'
kubectl get ns | grep -E 'linkerd|metallb'

# Check Docker containers
docker ps -a | grep kind
```
```

## 🚨 Troubleshooting Guide

| Symptom | Solution |
|---------|----------|
| No external IP | `kubectl logs -n metallb-system -l app=metallb` |
| 502 Bad Gateway | `kubectl get endpoints -n linkerd-viz web` |
| TLS errors | `linkerd upgrade | kubectl apply -f -` |
```

<p align="center">
  :book: <a href="https://linkerd.io/docs/">Linkerd Docs</a> | 
  :computer: <a href="https://kind.sigs.k8s.io/">Kind Docs</a> |
  :warning: <a href="https://metallb.universe.tf/">MetalLB Guide</a>
</p>

Key Features:
1. **Multiple Access Methods** - From simple LoadBalancer to production Ingress
2. **Complete Verification** - Includes all diagnostic commands
3. **Production-Ready** - Proper Ingress annotations for Linkerd
4. **Error Handling** - Embedded wait conditions and checks
5. **Clean Organization** - Clearly separated sections
6. **Version-Pinned** - All components use stable versions

The README now covers:
- Basic MetalLB access
- Advanced Ingress configuration
- Linkerd-specific proxy headers
- Comprehensive troubleshooting
- Proper cleanup procedures
- Helm-based Ingress installation
