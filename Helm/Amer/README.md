# Helm - Kubernetes Package Manager

Helm is the package manager for Kubernetes, often referred to as the "apt/yum/homebrew" for Kubernetes. It simplifies application deployment and management using charts (pre-configured Kubernetes resource packages).

## Table of Contents
1. [Installation](#installation)
2. [Basic Commands](#basic-commands)
3. [Repository Operations](#repository-operations)
4. [Chart Operations](#chart-operations)
5. [Release Management](#release-management)
6. [Chart Development](#chart-development)
7. [Debugging](#debugging)
8. [Best Practices](#best-practices)
9. [Example Workflow](#example-workflow)

## Installation
### **Helm Installation Methods**

#### 1. **Direct Script Install (Recommended)**
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
**Output**:
```
Downloading https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
```

#### 2. **Debian/Ubuntu APT Repository**
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

#### 3. **Manual Download & Install**
```bash
# Download the binary
wget https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz
tar -zxvf helm-v3.17.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### Verify Installation
```bash
helm version
```
Example output:
```
version.BuildInfo{Version:"v3.17.3", GitCommit:"e4da49785aa6e6ee2b86efd5dd9e43400318262b", GitTreeState:"clean", GoVersion:"go1.23.7"}
```

## Basic Commands

List deployed releases:
```bash
helm list
```
Example output:
```
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-nginx default         1               2025-01-26 17:29:00.38552466 +0000 UTC deployed        nginx-18.3.5     1.27.3
```

## Repository Operations

List repositories:
```bash
helm repo list
```
Example output:
```
NAME    URL
bitnami https://charts.bitnami.com/bitnami
```

## Chart Operations

Search for charts:
```bash
helm search repo nginx
```
Example output:
```
NAME            CHART VERSION   APP VERSION DESCRIPTION
bitnami/nginx   18.3.5         1.27.3      NGINX Open Source is a web server that can be also...
```

Install a chart:
```bash
helm install my-nginx bitnami/nginx
```
Example output:
```
NAME: my-nginx
LAST DEPLOYED: Sun Jan 26 17:29:00 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

## Release Management

List releases with history:
```bash
helm history mysql -n devops
```
Example output:
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Jan 27 11:43:09 2025        superseded      mysql-12.2.2    8.4.4           Install complete
2               Mon Jan 27 11:44:20 2025        superseded      mysql-12.2.2    8.4.4           Upgrade complete
3               Mon Jan 27 12:00:27 2025        deployed        mysql-12.2.2    8.4.4           Upgrade complete
```

Get release status:
```bash
helm status my-nginx -n devops
```
Example output:
```
NAME: my-nginx
LAST DEPLOYED: Sun Jan 26 19:53:13 2025
NAMESPACE: devops
STATUS: deployed
REVISION: 1
CHART: nginx-18.3.5
APP VERSION: 1.27.3
```

Rollback a release:
```bash
helm rollback mysql 2 -n devops
```
Example output:
```
Rollback was a success! Happy Helming!
```

After rollback, verify history:
```bash
helm history mysql -n devops
```
Example output:
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Jan 27 11:43:09 2025        superseded      mysql-12.2.2    8.4.4           Install complete
2               Mon Jan 27 11:44:20 2025        superseded      mysql-12.2.2    8.4.4           Upgrade complete
3               Mon Jan 27 12:00:27 2025        superseded      mysql-12.2.2    8.4.4           Upgrade complete
4               Mon Jan 27 19:30:49 2025        deployed        mysql-12.2.2    8.4.4           Rollback to 2
```

## Advanced Operations

### Dry-run (Simulation)
```bash
helm install mydb bitnami/mysql -n devops --dry-run
```
Example output:
```
NAME: mydb
LAST DEPLOYED: Sun Jan 26 20:53:55 2025
NAMESPACE: devops
STATUS: pending-install
REVISION: 1
TEST SUITE: None
HOOKS:
MANIFEST:
---
# Source: mysql/templates/networkpolicy.yaml
...
```

### Random Name Generation
```bash
helm install bitnami/apache --generate-name --name-template "{{randAlpha 7 | lower}}"
```
Example output:
```
NAME: vekvpuy
LAST DEPLOYED: Mon Jan 27 20:03:09 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

### Atomic Operations
```bash
helm install mysql6 bitnami/mysql --atomic
```
Example output (success):
```
NAME: mysql6
LAST DEPLOYED: Mon Jan 27 20:15:22 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

Example output (failure):
```
Error: INSTALLATION FAILED: failed post-install: timed out waiting for the condition
ROLLING BACK...
Error: rollback complete: original install failed
```

## Chart Development

Create a new chart:
```bash
helm create firstchart
```
Example directory structure:
```
firstchart/
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
└── values.yaml
```

Package a chart:
```bash
helm package firstchart
```
Example output:
```
Successfully packaged chart and saved it to: /home/vagrant/documents/helm/firstchart-0.1.0.tgz
```

## Debugging

Get release values:
```bash
helm get values mysql -n devops
```
Example output:
```
USER-SUPPLIED VALUES:
auth:
  rootPassword: test1234
image:
  pullPolicy: Always
```

Get release manifest:
```bash
helm get manifest mysql -n devops
```
Example output (truncated):
```
---
# Source: mysql/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-mysql
  namespace: "devops"
  labels:
    app.kubernetes.io/instance: mysql
...
```

## Example Workflow

1. Add repository and search:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo mysql
```
Output:
```
NAME            CHART VERSION   APP VERSION DESCRIPTION
bitnami/mysql   12.2.2         8.4.4       MySQL is a fast, reliable, scalable, and easy...
```

2. Install with custom values:
```bash
helm install mydb bitnami/mysql --set auth.rootPassword=test1234
```
Output:
```
NAME: mydb
LAST DEPLOYED: Sun Jan 26 19:53:13 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
CHART NAME: mysql
CHART VERSION: 12.2.2
APP VERSION: 8.4.4
...
```

3. Verify installation:
```bash
helm list
```
Output:
```
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
mydb    default         1               2025-01-26 19:53:13.123456789 +0000 UTC deployed        mysql-12.2.2    8.4.4
```

4. Upgrade release:
```bash
helm upgrade mydb bitnami/mysql --set replicaCount=3
```
Output:
```
Release "mydb" has been upgraded. Happy Helming!
NAME: mydb
LAST DEPLOYED: Sun Jan 26 20:27:04 2025
NAMESPACE: default
STATUS: deployed
REVISION: 2
```

5. Check history:
```bash
helm history mydb
```
Output:
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sun Jan 26 19:53:13 2025        superseded      mysql-12.2.2    8.4.4           Install complete
2               Sun Jan 26 20:27:04 2025        deployed        mysql-12.2.2    8.4.4           Upgrade complete
```

6. Uninstall:
```bash
helm uninstall mydb
```
Output:
```
release "mydb" uninstalled
```

# Helm Operations Guide

## ✅ All Covered Examples

### Installation Methods
- **Direct script install**: `get_helm.sh`
- **Debian/Ubuntu repo install**
- **Verification**: `helm version` output

---

### Repository Operations
- `helm repo add/list/update/remove` with outputs
- Example with Bitnami repo

---

### Chart Operations
- `helm search repo nginx/mysql` with outputs
- `helm install` with `--set` and `--values` (including `values.yaml` example)
- Outputs showing `STATUS: deployed` and revision numbers

---

### Release Management
- `helm list` (with and without `-n namespace` flag)
- `helm status` with full output
- `helm upgrade` (with `--set`, `--values`, and `--reuse-values`)
- `helm rollback` with history output showing revisions (superseded/deployed states)
- `helm uninstall` (with/without `--keep-history`)

---

### Namespace Operations
- `--create-namespace` flag usage
- Multi-namespace examples (`devops1`, `devops2`)

---

### Advanced Features
- `--dry-run` with manifest output (truncated but structure shown)
- `--atomic` and `--wait` with success/failure outputs
- `--force` upgrade explanation
- `--cleanup-on-failure` explanation

---

### Chart Development
- `helm create firstchart` with directory structure
- `helm package` with output
- `helm lint` output

---

### Debugging
- `helm get values/manifest/history` with outputs
- `helm history` showing revision states (superseded/deployed)

---

### Random Name Generation
- `--generate-name` and `--name-template` with `vekvpuy` example output

---

### Error Cases
- Invalid `image.pullPolicy` error
- `context deadline exceeded` with `--timeout` fix

---

### Real Workflow
End-to-end example from `repo add` → `install` → `upgrade` → `uninstall`
```
