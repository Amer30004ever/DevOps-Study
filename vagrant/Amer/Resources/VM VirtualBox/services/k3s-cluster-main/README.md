# K3s Cluster with Vagrant

A lightweight Kubernetes cluster setup using K3s, automated with Vagrant for local development and testing.

## Features

- Single-command cluster provisioning
- 1 Control Plane (Master) node + 2 Worker nodes
- Automatic DNS configuration
- Idempotent provisioning scripts
- Private network isolation (192.168.56.0/24)

## Prerequisites

- [Vagrant](https://www.vagrantup.com/) (>= 2.3.0)
- [VirtualBox](https://www.virtualbox.org/) (>= 6.1)
- 8GB+ RAM (4GB minimum)
- 20GB+ free disk space
- bash/zsh terminal

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/ziyad-tarek1/k3s-cluster.git
   cd k3s-cluster
   ```

2. **Review configuration** (optional)
   - Edit `Vagrantfile` for resource allocation
   - Update `K3S_TOKEN` in Vagrantfile for security

3. **Start the cluster**
   ```bash
   vagrant up
   ```

4. **Verify installation** (after provisioning completes)
   ```bash
   vagrant ssh controlplane
   kubectl get nodes
   ```

## Cluster Details

| Node Name     | IP Address      | Role    | CPU | Memory |
|---------------|-----------------|---------|-----|--------|
| controlplane1  | 192.168.56.101  | Master  | 2   | 2GB    |
| node011        | 192.168.56.102  | Worker  | 2   | 1GB    |
| node022        | 192.168.56.103  | Worker  | 2   | 1GB    |



## Usage

### Accessing Nodes
```bash
# Connect to master node
vagrant ssh controlplane

# Connect to worker nodes
vagrant ssh node01
vagrant ssh node02
```

### Cluster Management
```bash
# Check cluster status
kubectl get nodes -o wide

# Deploy test application
kubectl create deployment nginx --image=nginx:alpine
kubectl expose deployment nginx --port=80

# View cluster info
kubectl cluster-info
```

### VM Management
```bash
# Stop cluster
vagrant halt

# Restart cluster
vagrant up

# Destroy cluster
vagrant destroy -f

# SSH to specific node
vagrant ssh node01
```

## Troubleshooting

### Common Issues
1. **SSH Connection Failed**
   - Verify VirtualBox network settings
   - Check host firewall rules
   - Run `vagrant reload --provision`

2. **Worker Node Not Joining**
   ```bash
   # Check agent logs
   journalctl -u k3s-agent -xe

   # Verify master API accessibility
   nc -zv 192.168.56.101 6443
   ```

3. **DNS Resolution Issues**
   ```bash
   systemctl status systemd-resolved
   cat /etc/resolv.conf
   ```
4. **Login into the K3s-master node and run the below commands**
   ```bash
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
    sudo chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml
   ```
5. **copy the Token**
    ```bash
     sudo cat /var/lib/rancher/k3s/server/node-token
   ```
6. **Login into both the worker nodes**
    ```bash
     curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.101:6443 K3S_TOKEN=(Token copied from the master node[step 5) sh -
   ```
7. **can be verified**
    ```bash
     kubectl get nodes
   ```
### Log Locations
- Master node: `journalctl -u k3s`
- Worker nodes: `journalctl -u k3s-agent`
- Provisioning logs: `vagrant up --debug`

## Customization

### Modify Cluster Setup
1. **Change Resources**  
   Edit `Vagrantfile`:
   ```ruby
   vb.memory = 4096 # Increase memory
   vb.cpus = 4      # Add more CPUs
   ```

2. **Add More Nodes**  
   Duplicate worker configuration in `Vagrantfile`

3. **Change K3s Configuration**  
   Modify provisioning scripts:
   ```bash
   # In bootstrap_master.sh
   INSTALL_K3S_EXEC="--disable=traefik --write-kubeconfig-mode 644"
   ```
## After setting up your cluster enable kubectl autocompletion from the below link

```bash
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```
## Security Note
This setup is configured for **development purposes only**. For production use:
- Rotate the default K3s token
- Enable Kubernetes RBAC
- Configure proper network policies
- Use TLS certificates for API server

### 👨‍💻 License
This project is licensed under a custom license. Unauthorized use, distribution, or modification is prohibited. Refer to the LICENSE file for details.

---

### 💡 Contributors
    - Ziyad Tarek Saeed - Author and Maintainer.

Happy vagranting! 🚀
