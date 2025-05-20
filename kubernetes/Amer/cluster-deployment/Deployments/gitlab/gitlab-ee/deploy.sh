#!/bin/bash
set -e

# Create mount directories and set permissions
sudo mkdir -p /mnt/data/gitlab
sudo chown -R $USER:$USER /mnt/data/gitlab
sudo chmod -R 755 /mnt/data/gitlab

# Create backup volume directory
sudo mkdir -p /mnt/data/gitlab/backups
sudo chown -R $USER:$USER /mnt/data/gitlab/backups
sudo chmod -R 755 /mnt/data/gitlab/backups

# Function to get the node IP
get_node_ip() {
  hostname -I | awk '{print $1}'
}

# Get the node IP
NODE_IP=$(get_node_ip)
echo "Using node IP: $NODE_IP"

# Create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: gitlab
EOF

# Create PostgreSQL secret
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: gitlab
type: Opaque
data:
  username: cG9zdGdyZXM=  # base64 for "postgres"
  password: cG9zdGdyZXNAMTIz  # base64 for "postgres@123"
EOF

# Create StorageClass if not exists
if ! kubectl get storageclass standard &> /dev/null; then
  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
fi

# Create Persistent Volumes
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  local:
    path: /mnt/data/gitlab
  volumeMode: Filesystem
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - worker01
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab-backup-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  local:
    path: /mnt/data/gitlab/backups
  volumeMode: Filesystem
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - worker01
EOF

# Create Persistent Volume Claims
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-pvc
  namespace: gitlab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-backup-pvc
  namespace: gitlab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
EOF

# Deploy PostgreSQL with proper security context and resource limits
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: gitlab
spec:
  serviceName: "postgres"
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      securityContext:
        fsGroup: 999  # PostgreSQL group
      containers:
        - name: postgres
          image: postgres:13.4
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            - name: POSTGRES_DB
              value: "postgres"
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: postgres-storage
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          securityContext:
            runAsUser: 999  # PostgreSQL user
            runAsGroup: 999
  volumeClaimTemplates:
    - metadata:
        name: postgres-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: standard
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: gitlab
spec:
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    app: postgres
EOF

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to become ready..."
kubectl wait --namespace gitlab --for=condition=ready pod -l app=postgres --timeout=300s

# Deploy GitLab with proper resource allocation
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab
  namespace: gitlab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gitlab
  template:
    metadata:
      labels:
        app: gitlab
    spec:
      containers:
        - name: gitlab
          image: gitlab/gitlab-ee:15.11.8-ee.0
          ports:
            - containerPort: 80
            - containerPort: 443
            - containerPort: 22
          env:
            - name: GITLAB_OMNIBUS_CONFIG
              value: |
                external_url 'http://${NODE_IP}:30080';
                gitlab_rails['db_adapter'] = 'postgresql'
                gitlab_rails['db_encoding'] = 'utf8'
                gitlab_rails['db_database'] = 'postgres'
                gitlab_rails['db_username'] = 'postgres'
                gitlab_rails['db_password'] = 'postgres@123'
                gitlab_rails['db_host'] = 'postgres'
                gitlab_rails['db_port'] = 5432
                gitlab_rails['backup_path'] = '/var/opt/gitlab/backups'
                gitlab_rails['backup_keep_time'] = 604800
          volumeMounts:
            - name: gitlab-storage
              mountPath: /var/opt/gitlab
            - name: gitlab-backup
              mountPath: /var/opt/gitlab/backups
          resources:
            requests:
              memory: "2Gi"
              cpu: "1"
            limits:
              memory: "4Gi"
              cpu: "2"
          readinessProbe:
            httpGet:
              path: /users/sign_in
              port: 80
            initialDelaySeconds: 180  # Increased for GitLab initialization
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /users/sign_in
              port: 80
            initialDelaySeconds: 240  # Increased for GitLab initialization
            periodSeconds: 20
      volumes:
        - name: gitlab-storage
          persistentVolumeClaim:
            claimName: gitlab-pvc
        - name: gitlab-backup
          persistentVolumeClaim:
            claimName: gitlab-backup-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: gitlab-service
  namespace: gitlab
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 30080
    - name: https
      port: 443
      targetPort: 443
    - name: ssh
      port: 22
      targetPort: 22
  selector:
    app: gitlab
EOF

# Output the GitLab access information
echo "GitLab setup is complete."
echo "Access GitLab at: http://${NODE_IP}:30080"
echo "Initial root password can be found by running:"
echo "kubectl exec -it \$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.name}') -n gitlab -- grep 'Password:' /etc/gitlab/initial_root_password"
