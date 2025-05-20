#!/bin/bash

set -e

#creating mount dir and giving permission
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

#gitlab.yml
cat <<EOF | kubectl apply -f -
# 1. Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: gitlab
---
# 2. Secret for PostgreSQL credentials
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: gitlab
type: Opaque
data:
  username: cG9zdGdyZXM=  # base64 for "postgres"
  password: cG9zdGdyZXNAMTIz  # base64 for "postgres@123"
---
# 3. ConfigMap for external DB config
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-config
  namespace: gitlab
data:
  POSTGRES_HOST: "192.168.2.151"
  POSTGRES_PORT: "5432"
  POSTGRES_DB: "postgres"
  POSTGRES_USER: "postgres"
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: gitlabs.apps.gitlab.com
spec:
  group: apps.gitlab.com
  names:
    kind: GitLab
    listKind: GitLabList
    plural: gitlabs
    shortNames:
    - gl
    singular: gitlab
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - jsonPath: .status.phase
      name: STATUS
      type: string
    - jsonPath: .status.version
      name: VERSION
      type: string
    name: v1beta1
    schema:
      openAPIV3Schema:
        description: GitLab is a complete DevOps platform, delivered in a single application.
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: Specification of the desired behavior of a GitLab instance.
            properties:
              chart:
                description: The specification of GitLab Chart that is used to deploy
                  the instance.
                properties:
                  values:
                    description: ChartValues is the set of Helm values that is used
                      to render the GitLab Chart.
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  version:
                    description: ChartVersion is the semantic version of the GitLab
                      Chart.
                    pattern: ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
                    type: string
                type: object
            type: object
          status:
            description: Most recently observed status of the GitLab instance. It
              is read-only to the user.
            properties:
              conditions:
                items:
                  description: "Condition contains details for one aspect of the current
                    state of this API Resource."
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase.
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
              phase:
                type: string
              version:
                type: string
            required:
            - conditions
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---
# Source: gitlab-operator/templates/app/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-app-nonroot
  namespace: gitlab
  annotations:
    {}

---
# Source: gitlab-operator/templates/manager/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-manager
  namespace: gitlab
---
# Source: gitlab-operator/templates/nginx-ingress/serviceaccount.yaml
# Source: gitlab/charts/nginx-ingress/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-nginx-ingress
  namespace: gitlab
---
# Source: gitlab-operator/templates/prometheus/server/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-prometheus-server
  namespace: gitlab
---
# Source: gitlab-operator/templates/app/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-app-role-nonroot
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - nonroot-v2
  resources:
  - securitycontextconstraints
  verbs:
  - use
---
# Source: gitlab-operator/templates/manager/metrics-auth-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-metrics-auth-role
rules:
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
---
# Source: gitlab-operator/templates/manager/metrics-reader-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-metrics-reader
rules:
- nonResourceURLs:
  - /metrics
  verbs:
  - get
---
# Source: gitlab-operator/templates/manager/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-manager-role
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - statefulsets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps.gitlab.com
  resources:
  - gitlabs
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps.gitlab.com
  resources:
  - gitlabs/finalizers
  verbs:
  - update
- apiGroups:
  - apps.gitlab.com
  resources:
  - gitlabs/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - cert-manager.io
  resources:
  - certificates
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - cert-manager.io
  resources:
  - issuers
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - namespaces
  - secrets
  - services
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterroles
  - clusterrolebindings
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - roles
  - rolebindings
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
  - patch
  - update
  - list
  - watch
  - create
---
# Source: gitlab-operator/templates/nginx-ingress/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-nginx-ingress-role
rules:
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
---
# Source: gitlab-operator/templates/prometheus/server/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gitlab-prometheus-server
rules:
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
  - list
  - watch
---
# Source: gitlab-operator/templates/app/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-app-rolebinding-nonroot
  namespace: gitlab
subjects:
- kind: ServiceAccount
  name: gitlab-app-nonroot
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-app-role-nonroot
  apiGroup: rbac.authorization.k8s.io
---
# Source: gitlab-operator/templates/manager/metrics-auth-clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-metrics-auth-binding
subjects:
- kind: ServiceAccount
  name: gitlab-manager
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-metrics-auth-role
  apiGroup: rbac.authorization.k8s.io
---
# Source: gitlab-operator/templates/manager/metrics-reader-clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-metrics-reader-binding
subjects:
- kind: ServiceAccount
  name: gitlab-manager
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-metrics-reader
  apiGroup: rbac.authorization.k8s.io
---
# Source: gitlab-operator/templates/manager/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-manager-rolebinding
  namespace: gitlab
subjects:
- kind: ServiceAccount
  name: gitlab-manager
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-manager-role
  apiGroup: rbac.authorization.k8s.io
---
# Source: gitlab-operator/templates/nginx-ingress/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-nginx-ingress-rolebinding
  namespace: gitlab
subjects:
- kind: ServiceAccount
  name: gitlab-nginx-ingress
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-nginx-ingress-role
  apiGroup: rbac.authorization.k8s.io
---
# Source: gitlab-operator/templates/prometheus/server/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-prometheus-server-rolebinding
  namespace: gitlab
subjects:
- kind: ServiceAccount
  name: gitlab-prometheus-server
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: gitlab-prometheus-server
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Service
metadata:
  name: gitlab-service
  namespace: gitlab
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
  selector:
    app: gitlab
EOF

#gitlab-pv.yaml
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
    path: /mnt/data/gitlab  # Adjust the path as needed
  volumeMode: Filesystem
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - worker01  # Ensure this matches the node where the local volume is located
EOF

#gitlab-pvc.yaml
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
EOF

#gitlab-deployment.yaml
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
          image: gitlab/gitlab-ee:latest
          ports:
            - containerPort: 80
          env:
            - name: GITLAB_OMNIBUS_CONFIG
              value: |
                external_url 'http://192.168.2.151:30080';
                gitlab_rails['db_adapter'] = 'postgresql'
                gitlab_rails['db_encoding'] = 'utf8'
                gitlab_rails['db_database'] = 'postgres'
                gitlab_rails['db_username'] = 'postgres'
                gitlab_rails['db_password'] = 'postgres@123'
                gitlab_rails['db_host'] = '192.168.2.151'
                gitlab_rails['db_port'] = 5432
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
            initialDelaySeconds: 60
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /users/sign_in
              port: 80
            initialDelaySeconds: 120
            periodSeconds: 20
      volumes:
        - name: gitlab-storage
          persistentVolumeClaim:
            claimName: gitlab-pvc
		- name: gitlab-backup
		  persistentVolumeClaim:
			claimName: gitlab-backup-pvc

EOF

# PostgreSQL Storage.yaml
cat <<EOF | kubectl apply -f -
# 7.  PostgreSQL Storage Deployment 
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
      containers:
        - name: postgres
          image: postgres:latest
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
          volumeMounts:
            - name: postgres-storage
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
    - metadata:
        name: postgres-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi

EOF

# Create PV for backups
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab-backup-pv
  namespace: gitlab
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

# Create PVC for backups
kubectl apply -f - <<EOF
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


# Output the Gitlab access information
echo "Gitlab setup is complete."
echo "Access Gitlab at: http://$NODE_IP:30080"

