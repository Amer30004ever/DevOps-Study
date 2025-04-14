#!/bin/bash

set -e

# Creating mount dir and giving permission
sudo mkdir -p /mnt/data/jenkins
sudo chmod -R 777 /mnt/data/jenkins

# Function to get the node IP
get_node_ip() {
  local node_ip=$(hostname -I | awk '{print $1}')
  echo "Using node IP: $node_ip"
  echo "$node_ip"
}

# Get the node IP
NODE_IP=$(get_node_ip)

# Create namespace for Jenkins
kubectl create namespace jenkins || echo "Namespace 'jenkins' already exists."

# Create PersistentVolume and PersistentVolumeClaim for Jenkins
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv-volume
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/jenkins"
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pv-claim
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF

# Deploy Jenkins
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-server
  template:
    metadata:
      labels:
        app: jenkins-server
    spec:
      serviceAccountName: default
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        - containerPort: 50000
        resources:
          requests:
            memory: "500Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1"
        volumeMounts:
        - name: jenkins-data
          mountPath: /var/jenkins_home
      volumes:
      - name: jenkins-data
        persistentVolumeClaim:
          claimName: jenkins-pv-claim
EOF

# Expose Jenkins with a NodePort Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
spec:
  selector:
    app: jenkins-server
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: 32000
  type: NodePort
EOF

# Deploy Ingress for Jenkins
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: jenkins.homelab.com
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: jenkins-service
            port:
              number: 8080
EOF

# Output the Jenkins access information
echo "Jenkins setup is complete."
echo "Access Jenkins at: http://jenkins.homelab.com"

