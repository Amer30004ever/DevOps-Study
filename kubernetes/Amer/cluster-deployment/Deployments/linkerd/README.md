# 🚀 Linkerd Service Mesh Installation on Kind

![Linkerd Logo](https://linkerd.io/images/identity/svg/linkerd_logo_vertical_black.svg)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Kind](https://img.shields.io/badge/Kind-326CE5?logo=kubernetes&logoColor=white)

A complete guide to installing Linkerd 2.14 with dashboard access on a Kind Kubernetes cluster.

## 📋 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 🐳
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) v0.17+ 🏗️
- [kubectl](https://kubernetes.io/docs/tasks/tools/) v1.27+ ⚙️
- 4GB+ RAM 💾
- 2+ CPU cores 🖥️

## 🛠️ Installation Steps

### 1. Create Kind Cluster
```bash
cat > kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000  # Dashboard port
    hostPort: 8080
    protocol: TCP
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: "cpu=500m,memory=500Mi"
        kube-reserved: "cpu=500m,memory=500Mi"
EOF

kind create cluster --config kind-config.yaml
```

### 2. Install Linkerd CLI
```bash
curl -fsL https://github.com/linkerd/linkerd2/releases/download/stable-2.14.0/linkerd2-cli-stable-2.14.0-linux-amd64 -o linkerd
chmod +x linkerd
sudo mv linkerd /usr/local/bin/
linkerd version
```

### 3. Install Control Plane
```bash
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
linkerd check
```

### 4. Install Viz Extension (Dashboard)
```bash
linkerd viz install | kubectl apply -f -
linkerd viz check
```

## 🌐 Accessing the Dashboard

### Option 1: NodePort (Recommended)
```bash
kubectl patch svc -n linkerd-viz web -p '{"spec":{"type":"NodePort","ports":[{"name":"http","port":8084,"nodePort":30000}]}}'
```
🔗 Access: [http://localhost:8080](http://localhost:8080)

### Option 2: Port Forwarding
```bash
kubectl port-forward -n linkerd-viz svc/web 8084:8084
```
🔗 Access: [http://localhost:8084](http://localhost:8084)

## 🔍 Verification
```bash
kubectl get pods -n linkerd
kubectl get pods -n linkerd-viz
linkerd check
linkerd viz check
```

## 🧹 Cleanup
```bash
kind delete cluster
sudo rm /usr/local/bin/linkerd
rm -rf ~/.linkerd2
```

## 📚 Resources
- [Linkerd Documentation](https://linkerd.io/docs/) 📄
- [Kind Documentation](https://kind.sigs.k8s.io/docs/) 📖
- [Service Mesh Comparison](https://servicemesh.es/) ⚖️

---

<p align="center">
  Made with ❤️ by Amer Magdi | 
  <a href="https://linkerd.io/community/">Join the Linkerd Community</a> 👥
</p>
```

## Key Features:

1. **Professional Header** with Linkerd and Kubernetes badges
2. **Clear Icons** for each section (📋, 🛠️, 🌐, etc.)
3. **Code Blocks** with proper syntax highlighting
4. **Multiple Access Methods** with recommended approach
5. **Verification Steps** to ensure proper installation
6. **Cleanup Instructions** for complete removal
7. **Responsive Layout** that works on GitHub/GitLab
8. **Community Links** for further learning

You can copy this directly into a `README.md` file in your project directory. The emoji icons make it visually appealing while maintaining professional documentation standards.