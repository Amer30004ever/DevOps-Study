# AWX Installation Guide

This document provides step-by-step instructions for installing AWX (Ansible Web eXecutable) using Helm on a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster (v1.19+ recommended)
- Helm (v3.0+)
- kubectl configured to access your cluster
- StorageClass named "standard" available in your cluster

## Installation Steps

### 1. Download the AWX Helm Chart

```bash
wget https://adwerx.github.io/charts/awx-3.4.3.tgz
```

### 2. Configure AWX Settings

Create or edit the `values.yaml` file with your preferred editor:

```bash
sudo vi values.yaml
```

Paste the following configuration, adjusting values as needed:

```yaml
# AWX Admin Settings
secretKey: "b4bd3ba1ed33a670ba99bb4362278d6e9ddae73328870799da8bdb74a23e5939"  # Must be at least 32 characters
defaultAdminUser: "admin"
defaultAdminPassword: "plaintextpassword123"  # Change to a secure password

# PostgreSQL Configuration
postgresql:
  enabled: true
  postgresqlUsername: awx
  postgresqlPassword: "plaintextpassword123"  # Change to match admin password or another secure password
  postgresqlDatabase: awx
  persistence:
    enabled: true
    size: 1Gi
    storageClass: standard  # Must exist in your cluster
  global:
    storageClass: standard
  sharedBuffers: 128MB
  maxConnections: 100

# AWX Service Configuration
service:
  type: NodePort
  port: 80
  nodePort: 31125  # Static NodePort
  targetPort: 8052

# Enable DB migrations on startup
env:
  - name: MIGRATE_AWX_DATABASE_ON_STARTUP
    value: "true"
```

### 3. Install AWX

Run the following commands to clean up any previous installation and deploy AWX:

```bash
helm uninstall my-awx || echo "No previous release found, proceeding with install"
kubectl delete pvc data-my-awx-postgresql-0 || echo "PVC not found, proceeding"
helm install my-awx ./awx-3.4.3.tgz --values=values.yaml
```

### 4. Access AWX

#### Option 1: Port Forwarding (Recommended for testing)

```bash
nohup kubectl port-forward --address 0.0.0.0 svc/my-awx 8080:80 &
```

Access AWX at:
```
http://<your-machine-ip>:8080/
```

#### Option 2: NodePort (For production)

After installation, find your NodePort:
```bash
kubectl get svc my-awx
```

Access AWX at:
```
http://<node-ip>:<node-port>/
```

### 5. Login Credentials

- **Username**: `admin`
- **Password**: `plaintextpassword123` (or whatever you set in values.yaml)

## Verification

Check that all pods are running:
```bash
kubectl get pods
```

Check service details:
```bash
kubectl get svc my-awx
```

## Troubleshooting

1. **Connection Issues**:
   - Verify firewall rules allow traffic to the NodePort
   - Check pod logs: `kubectl logs <pod-name> -c web`

2. **Database Problems**:
   - Check PostgreSQL logs: `kubectl logs my-awx-postgresql-0`

3. **Installation Errors**:
   - Verify your Kubernetes cluster meets requirements
   - Check Helm version compatibility

## Maintenance

To upgrade AWX:
```bash
helm upgrade my-awx ./awx-3.4.3.tgz --values=values.yaml
```

To uninstall AWX:
```bash
helm uninstall my-awx
kubectl delete pvc data-my-awx-postgresql-0
```

## Security Notes

- Always change default passwords in production
- Consider using Ingress with TLS for production deployments
- Regularly back up your PostgreSQL data

For more information, refer to the official AWX documentation.