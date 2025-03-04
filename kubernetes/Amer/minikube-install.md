#!/bin/bash

# Function to log messages
log() {
    echo -e "\n[INFO] $1\n"
}

# Define the stable version of kubectl to install
STABLE_KUBECTL_VERSION="v1.28.2"

# Install prerequisites
log "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Add Kubernetes repository and key
log "Adding Kubernetes repository and key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Update package index and install kubectl
log "Installing kubectl..."
sudo apt-get update
sudo apt-get install -y kubectl

# Verify kubectl installation
log "Verifying kubectl installation..."
if ! kubectl version --client; then
    echo "[ERROR] kubectl installation failed. Exiting."
    exit 1
fi

# Install kubectl manually (as a backup)
log "Installing kubectl manually (as a fallback)..."
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
else
    echo "[ERROR] Unsupported architecture: $ARCH. Exiting."
    exit 1
fi
curl -LO "https://dl.k8s.io/release/${STABLE_KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"

# Check if the file was successfully downloaded
if [ ! -f kubectl ] || [ $(file kubectl | grep -c "ELF") -eq 0 ]; then
    echo "[ERROR] Failed to download kubectl binary or invalid file. Exiting."
    exit 1
fi

chmod +x kubectl
mkdir -p ~/.local/bin
mv kubectl ~/.local/bin/kubectl
export PATH=$PATH:~/.local/bin

# Verify manual installation
log "Verifying manual kubectl installation..."
kubectl version --client || {
    echo "[ERROR] Manual kubectl installation failed. Exiting."
    exit 1
}

# Install Minikube
log "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Verify Minikube installation
log "Verifying Minikube installation..."
if ! minikube version; then
    echo "[ERROR] Minikube installation failed. Exiting."
    exit 1
fi

log "Installation of Kubernetes tools complete!"



-------------------------------------------------------------------------
Make the Script Executable:

chmod +x install_kubernetes_tools.sh


Run the Script

sudo ./install_kubernetes_tools.sh

