#!/bin/bash

# Set a namespace variable for reuse
NAMESPACE="amer-project"

# Create the namespace if it does not already exist
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Deploy the Pod and Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: amer4
  namespace: $NAMESPACE
  labels:
    app: amer4
spec:
  containers:
  - name: amer4
    image: amer30004ever/proj
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: "100m"      # Minimum CPU requested
        memory: "128Mi"  # Minimum memory requested
      limits:
        cpu: "500m"      # Maximum CPU allowed
        memory: "256Mi"  # Maximum memory allowed
  dnsPolicy: ClusterFirst
  restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: amer4-service
  namespace: $NAMESPACE
spec:
  type: NodePort
  selector:
    app: amer4
  ports:
  - name: http
    port: 80            # Service port
    targetPort: 80      # Target container port
    nodePort: 30000     # Fixed external port
EOF

# Output success message
echo "Pod 'amer4' and Service 'amer4-service' have been created in the '$NAMESPACE' namespace."
echo "Access the application using NodeIP:30000."

