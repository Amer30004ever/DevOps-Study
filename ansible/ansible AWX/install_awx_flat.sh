#!/bin/bash

# Step 1: Install Required Packages
sudo apt update && sudo apt install -y git make curl

# Step 2: Install Docker
sudo apt update && sudo apt install -y curl
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-registry
sudo usermod -aG docker $USER && newgrp docker

# Step 3: Install Minikube and kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
sudo snap install kubectl --classic

# Step 4: Start Minikube
minikube start --vm-driver=docker --addons=ingress

# Step 5: Deploy Ansible AWX via Operator
git clone https://github.com/ansible/awx-operator.git
cd awx-operator/
git checkout 2.19.0
export NAMESPACE=ansible-awx
make deploy

# Step 6: Verify AWX Operator Deployment
kubectl get pods -n $NAMESPACE

# Step 7: Create AWX Instance
cp awx-demo.yml awx-ubuntu.yml
sed -i 's/awx-demo/awx-ubuntu/g' awx-ubuntu.yml
kubectl create -f awx-ubuntu.yml -n $NAMESPACE

# Step 8: Access AWX Dashboard
echo "Getting AWX Dashboard URL..."
minikube service awx-ubuntu-service --url -n $NAMESPACE

# Step 9: Retrieve Admin Password
echo "Retrieving Admin Password..."
PASSWORD=$(kubectl get secret awx-ubuntu-admin-password -o jsonpath="{.data.password}" -n $NAMESPACE | base64 --decode)
echo "Username: admin"
echo "Password: $PASSWORD"

# Step 10: Port Forwarding (Optional)
echo "To access AWX locally, run the following command in a new terminal:"
echo "kubectl port-forward --address 0.0.0.0 svc/awx-ubuntu-service 8080:80 -n $NAMESPACE"

echo "Ansible AWX installation is complete!"
