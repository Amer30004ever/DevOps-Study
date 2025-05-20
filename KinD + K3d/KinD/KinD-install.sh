#!/bin/bash
set -e  # Exit on any error

# Install Docker
sudo apt update
sudo apt install docker.io -y

# Add user to Docker group
sudo usermod -aG docker $USER

# Verify Docker works (may fail until logout)
if ! docker ps &>/dev/null; then
    echo "Docker not working. Please log out/in or reboot, then re-run the script."
    exit 1
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install kind (latest version)
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/$(curl -s https://kind.sigs.k8s.io/dl/latest)/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

# Create kind cluster config
cat <<EOF > cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

# Create cluster
kind create cluster --config cluster.yaml

# Verify cluster
kubectl cluster-info
kubectl get nodes
