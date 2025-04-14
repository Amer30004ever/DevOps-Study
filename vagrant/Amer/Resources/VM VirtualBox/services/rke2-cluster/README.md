
# RKE2 Cluster with Vagrant

A lightweight Kubernetes cluster setup using RKE2, automated with Vagrant for local development and testing.

## Features

- Single-command cluster provisioning
- 1 Control Plane (Master) node + 1 Worker nodes
- Automatic DNS configuration
- Idempotent provisioning scripts
- Private network isolation (192.168.56.0/24)

## Prerequisites

- [Vagrant](https://www.vagrantup.com/) (>= 2.3.0)
- [VirtualBox](https://www.virtualbox.org/) (>= 6.1)
- 8GB+ RAM (4GB minimum)
- 20GB+ free disk space
- bash/zsh terminal
- install the vagrant-rke2 plugin by running:
  ```bash
  vagrant plugin install vagrant-rke2
  ```

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/ziyad-tarek1/rke2-cluster.git
   cd rke2-cluster
   ```

2. **Review configuration** (optional)
   - Edit `Vagrantfile` for resource allocation
   - Update `RKE2_TOKEN` in Vagrantfile for security

3. **Start the cluster**
   ```bash
   vagrant up
   ```

4. **Verify installation** (after provisioning completes)
   ```bash
   vagrant ssh rke2-controlplane
   kubectl get nodes
   ```

## Cluster Details

| Node Name     | IP Address      | Role    | CPU | Memory |
|---------------|-----------------|---------|-----|--------|
| rke2-controlplane  | 192.168.56.101  | Master  | 2   | 4GB    |
| rke2-worker1        | 192.168.56.102  | Worker  | 2   | 1GB    |

![image](https://github.com/user-attachments/assets/11df7ee8-bf34-412e-8b7c-2a92024c438f)


## Usage

### Accessing Nodes
```bash
# Connect to master node
vagrant ssh rke2-controlplane

# Connect to worker nodes
vagrant ssh rke2-worker1
```

### Cluster Management
```bash
# Check cluster status
kubectl get nodes -o wide
```
# Deploy test application
```bash
kubectl create deployment nginx --image=nginx:alpine
kubectl expose deployment nginx --port=80
```
![image](https://github.com/user-attachments/assets/1d7bf5c0-717e-4f1d-8366-ff60c9674cb7)

# View cluster info
```bash
kubectl cluster-info
```
![image](https://github.com/user-attachments/assets/2385b5b5-cc57-4e65-9a9f-82cae191d157)


### VM Management
```bash
# Stop cluster
vagrant halt

# Restart cluster
vagrant up

# Destroy cluster
vagrant destroy -f

# SSH to specific node
vagrant ssh rke2-worker1
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
   journalctl -u rke2-agent -xe

   # Verify master API accessibility
   nc -zv 192.168.56.101 6443
   ```

3. **DNS Resolution Issues**
   ```bash
   systemctl status systemd-resolved
   cat /etc/resolv.conf
   ```

### Log Locations
- Master node: `journalctl -u rke2`
- Worker nodes: `journalctl -u rke2-agent`
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


## After setting up your cluster enable kubectl autocompletion from the below link

```bash
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```
## Security Note
This setup is configured for **development purposes only**. For production use:
- Rotate the default rke2 token
- Enable Kubernetes RBAC
- Configure proper network policies
- Use TLS certificates for API server

### 👨‍💻 License
This project is licensed under a custom license. Unauthorized use, distribution, or modification is prohibited. Refer to the LICENSE file for details.

---

### 💡 Contributors
    - Ziyad Tarek Saeed - Author and Maintainer.

Happy vagranting! 🚀
