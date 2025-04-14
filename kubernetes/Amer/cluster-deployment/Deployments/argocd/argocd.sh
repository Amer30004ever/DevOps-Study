#!/bin/bash

set -e

# Function to get the node IP
get_node_ip() {
  local node_ip=$(hostname -I | awk '{print $1}')
  echo "Using node IP: $node_ip"
  echo "$node_ip"
}

# Get the node IP
NODE_IP=$(get_node_ip)

# Create namespace for ArgoCD
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."

# Apply the official ArgoCD manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Patch the ArgoCD Server deployment to use NodePort
kubectl patch svc argocd-server -n argocd --type=json -p='[
  {
    "op": "replace",
    "path": "/spec/type",
    "value": "NodePort"
  },
  {
    "op": "add",
    "path": "/spec/ports/0/nodePort",
    "value": 32004
  }
]'

# Wait for the ArgoCD Server pod to be ready
echo "Waiting for the ArgoCD Server to be ready..."
kubectl wait --namespace argocd --for=condition=ready pod --selector=app.kubernetes.io/name=argocd-server --timeout=120s

# Get the initial admin password
echo "Fetching the initial admin password..."
ARGOCD_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# Output the access information
echo "ArgoCD setup is complete."
echo "Access ArgoCD at: http://$NODE_IP:32004"
echo "Login with username: admin"
echo "Initial password: $ARGOCD_ADMIN_PASSWORD"

