#!/bin/bash

# Kubernetes 1.30.2 Cluster Setup Script for Ubuntu 22.04 LTS

# Prerequisites:
# - Ubuntu 22.04 LTS installed on all nodes.
# - Access to the internet.
# - User with `sudo` privileges.

# Function to disable swap
disable_swap() {
    echo "Disabling swap..."
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

# Function to enable IPv4 packet forwarding
enable_ipv4_forwarding() {
    echo "Enabling IPv4 packet forwarding..."
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
    sudo sysctl --system
    sysctl net.ipv4.ip_forward
}

# Function to install containerd
install_containerd() {
    echo "Installing containerd..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update && sudo apt-get install -y containerd.io
    sudo systemctl enable --now containerd
}

# Function to install CNI plugins
install_cni_plugins() {
    echo "Installing CNI plugins..."
    wget https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
    sudo mkdir -p /opt/cni/bin
    sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz
    rm cni-plugins-linux-amd64-v1.4.0.tgz
}

# Function to configure containerd for systemd support
configure_containerd() {
    echo "Configuring containerd for systemd support..."
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl status containerd
}

# Function to install kubeadm, kubelet, and kubectl
install_kubernetes_tools() {
    echo "Installing kubeadm, kubelet, and kubectl..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg

    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update -y
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}

# Function to initialize the Kubernetes cluster (Master Node Only)
initialize_cluster() {
    echo "Initializing Kubernetes cluster..."
    sudo kubeadm config images pull
    sudo kubeadm init
	##for multi masternode with loadbalancer : HAProxy
	#sudo kubeadm init --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --upload-certs
	#sudo kubeadm init --control-plane-endpoint "192.168.2.166:6443" --upload-certs

    # Configure kubectl for the current user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
	
#Apply a Network Plugin
	#Option 1: Calico
	#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
	
	#Option 2: Flannel
	#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
	
	#Option 3: Weave Net
    # Apply Weave CNI
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
}

# Function to join worker nodes to the cluster
join_worker_nodes() {
    echo "To join worker nodes, run the following command on each worker node:"
    echo "kubeadm join <MASTER_NODE_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>"
}

# Main script execution
disable_swap
enable_ipv4_forwarding
install_containerd
install_cni_plugins
configure_containerd
install_kubernetes_tools

# Check if the node is a master or worker
read -p "Is this node the master node? (y/n): " IS_MASTER

if [[ "$IS_MASTER" == "y" ]]; then
    initialize_cluster
    join_worker_nodes
else
    echo "This node is a worker node. Please run the join command provided by the master node."
fi

echo "Kubernetes cluster setup completed!"

sudo apt-get install -y containerd
sudo systemctl start containerd.service
mkdir -p $HOME/.kube
sudo scp  masternode01@masternode01:/etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config