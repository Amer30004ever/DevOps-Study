#!/bin/bash

# Script to install Traefik Ingress Controller and deploy sample applications
# Usage: ./install_traefik.sh

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if kubectl is installed
if ! command_exists kubectl; then
  echo "Error: kubectl is not installed. Please install it first."
  exit 1
fi

# Check if helm is installed
if ! command_exists helm; then
  echo "Error: helm is not installed. Please install Helm 3 first."
  exit 1
fi

# Set variables
TRAEFIK_NAMESPACE="traefik-v2"
NGINX_DEPLOY_FILE="nginx-deploy.yml"
NGINX_SVC_FILE="nginx-svc.yml"
NODEJS_DEPLOY_FILE="nodejs-deploy.yml"
NODEJS_SVC_FILE="nodejs-svc.yml"
TRAEFIK_INGRESS_FILE="traefik-ingress.yml"

# Step 1: Install Traefik Ingress Controller
echo "Adding Traefik Helm repository..."
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

echo "Creating namespace for Traefik..."
kubectl create ns $TRAEFIK_NAMESPACE

echo "Installing Traefik Ingress Controller..."
helm install --namespace=$TRAEFIK_NAMESPACE traefik traefik/traefik

echo "Waiting for Traefik to be ready..."
sleep 30

# Check Traefik service
kubectl get svc -n $TRAEFIK_NAMESPACE

# Step 2: Deploy sample applications
# Nginx application
echo "Deploying Nginx application..."
cat > $NGINX_DEPLOY_FILE <<EOF
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx-web
  namespace: default
  labels:
    app: nginx-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-web
  template:
    metadata:
      labels:
        app: nginx-web
    spec:
      containers:
      - name: nginx
        image: "nginx"
EOF

cat > $NGINX_SVC_FILE <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-web
  namespace: default
spec:
  selector:
    app: nginx-web
  ports:
  - name: http
    targetPort: 80
    port: 80
EOF

kubectl apply -f $NGINX_DEPLOY_FILE
kubectl apply -f $NGINX_SVC_FILE

# NodeJS application
echo "Deploying NodeJS application..."
cat > $NODEJS_DEPLOY_FILE <<EOF
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nodejs-app
  namespace: default
  labels:
    app: nodejs-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: nodejs-app
        image: "nginx"  # Using nginx as a placeholder, replace with your actual image
        ports:
          - containerPort: 3000
EOF

cat > $NODEJS_SVC_FILE <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app
  namespace: default
spec:
  selector:
    app: nodejs-app
  ports:
  - name: http
    targetPort: 3000
    port: 80
EOF

kubectl apply -f $NODEJS_DEPLOY_FILE
kubectl apply -f $NODEJS_SVC_FILE

# Step 3: Create Traefik Ingress Resource
echo "Creating Traefik Ingress Resource..."
cat > $TRAEFIK_INGRESS_FILE <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: nginxapp.example.com
    http:
      paths:
      - backend:
          service:
            name: nginx-web
            port:
              number: 80
        path: /
        pathType: Prefix
  - host: nodejsapp.example.com
    http:
      paths:
      - backend:
          service:
            name: nodejs-app
            port:
              number: 80
        path: /
        pathType: Prefix
EOF

kubectl apply -f $TRAEFIK_INGRESS_FILE

# Step 4: Verification
echo "Verifying installation..."
echo "Pods:"
kubectl get pods

echo "Deployments:"
kubectl get deploy

echo "Services:"
kubectl get svc

echo "Ingress:"
kubectl get ingress

# Step 5: Access Traefik Dashboard
echo ""
echo "To access the Traefik dashboard, run the following command in a separate terminal:"
echo "kubectl port-forward \$(kubectl get pods --selector \"app.kubernetes.io/name=traefik\" -n $TRAEFIK_NAMESPACE --output=name) -n $TRAEFIK_NAMESPACE --address 0.0.0.0 9000:9000"
echo ""
echo "Then access the dashboard at: http://127.0.0.1:9000/dashboard/"
echo ""

# Get Traefik LoadBalancer IP
echo "Traefik LoadBalancer details:"
kubectl get svc -n $TRAEFIK_NAMESPACE traefik -o wide

echo ""
echo "Installation completed. Please update your DNS records to point your domains to the Traefik LoadBalancer IP."
echo "Replace 'nginxapp.example.com' and 'nodejsapp.example.com' in the ingress resource with your actual domains."