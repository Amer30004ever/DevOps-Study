#!/bin/bash
kubectl create namespace amer-project || echo "Namespace 'amer-project' already exists."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: amer4
  name: amer4
  namespace: amer-project
spec:
  containers:
  - image: amer30004ever/proj
    name: amer4
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
EOF
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: amer4-service
  namespace: amer-project
spec:
  type: NodePort
  selector:
    run: amer4
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30000
EOF
