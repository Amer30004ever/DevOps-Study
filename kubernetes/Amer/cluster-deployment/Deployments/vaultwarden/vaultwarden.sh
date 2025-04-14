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

# Create namespace for Vaultwarden
kubectl create namespace vaultwarden || echo "Namespace 'vaultwarden' already exists."

# Create PersistentVolume and PersistentVolumeClaim for Vaultwarden
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vaultwarden-pv-volume
  namespace: vaultwarden
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/vaultwarden"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vaultwarden-pv-claim
  namespace: vaultwarden
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF

# Deploy Vaultwarden
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vaultwarden
  namespace: vaultwarden
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vaultwarden-server
  template:
    metadata:
      labels:
        app: vaultwarden-server
    spec:
      containers:
      - name: vaultwarden
        image: vaultwarden/server:latest
        ports:
        - containerPort: 80
        env:
        - name: ROCKET_PORT
          value: "80"
        volumeMounts:
        - name: vaultwarden-data
          mountPath: /data
      volumes:
      - name: vaultwarden-data
        persistentVolumeClaim:
          claimName: vaultwarden-pv-claim
EOF

# Expose Vaultwarden with a NodePort Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: vaultwarden-service
  namespace: vaultwarden
spec:
  selector:
    app: vaultwarden-server
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 32001
  type: NodePort
EOF

# Output the Vaultwarden access information
echo "Vaultwarden setup is complete."
echo "Access Vaultwarden at: http://$NODE_IP:32001"

