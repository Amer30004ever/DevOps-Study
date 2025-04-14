#!/bin/bash

set -e

sudo mkdir -p /var/lib/grafana/plugins
sudo chown -R 472:472 /var/lib/grafana/plugins
sudo chmod -R 777 /var/lib/grafana/plugins

sudo mkdir -p /mnt/data/grafana
sudo chown -R 472:472 /mnt/data/grafana
sudo chmod -R 777 /mnt/data/grafana

# Function to get the node IP
get_node_ip() {
  local node_ip=$(hostname -I | awk '{print $1}')
  echo "Using node IP: $node_ip"
  echo "$node_ip"
}

# Get the node IP
NODE_IP=$(get_node_ip)

# Create namespace for Grafana
kubectl create namespace grafana || echo "Namespace 'grafana' already exists."

# Create PersistentVolume and PersistentVolumeClaim for Grafana
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: grafana-pv-volume
  namespace: grafana
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/grafana"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pv-claim
  namespace: grafana
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF

# Deploy Grafana
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      securityContext:
        runAsUser: 472
        fsGroup: 472
        seLinuxOptions:
          level: s0:c123,c456
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_USER
          value: admin
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        volumeMounts:
        - name: grafana-data
          mountPath: /var/lib/grafana
          readOnly: false
      volumes:
      - name: grafana-data
        persistentVolumeClaim:
          claimName: grafana-pv-claim
EOF

sudo chmod -R 777 /var/lib/grafana/plugins

# Expose Grafana with a NodePort Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
  namespace: grafana
spec:
  selector:
    app: grafana
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 32003
  type: NodePort
EOF

# Output the Grafana access information
echo "Grafana setup is complete."
echo "Access Grafana at: http://$NODE_IP:32003"
echo "Login with username 'admin' and password 'admin'. Please change the password immediately after login."

