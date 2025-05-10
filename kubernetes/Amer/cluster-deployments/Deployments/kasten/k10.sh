#!/bin/bash

# Install Helm if not present
if ! command -v helm &>/dev/null; then
  echo "Helm not found. Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  rm get_helm.sh
else
  echo "Helm is already installed."
fi

# Add Kasten Helm repository and update
helm repo add kasten https://charts.kasten.io/
helm repo update

# Create the namespace if it doesn't exist
kubectl get namespace kasten-io &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating namespace kasten-io."
  kubectl create namespace kasten-io
else
  echo "Namespace kasten-io already exists."
fi

# Install Kasten K10 with NodePort and Token Authentication
echo "Installing Kasten K10..."
helm install k10 kasten/k10 --namespace=kasten-io \
    --set auth.tokenAuth.enabled=true \
    --set externalGateway.create=true \
    --set externalGateway.service.type=NodePort \
    --set externalGateway.service.nodePort=32005

# Wait for pods to be ready
echo "Waiting for Kasten K10 pods to be ready..."
kubectl wait --namespace kasten-io --for=condition=Ready pods --all --timeout=300s

# Output dashboard access information
NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[?(@.type=='InternalIP')].address}")
echo "Kasten K10 dashboard is now accessible at:"
echo "http://$NODE_IP:32005/k10/#/"

