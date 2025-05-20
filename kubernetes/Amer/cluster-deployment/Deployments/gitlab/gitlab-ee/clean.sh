#!/bin/bash
set -e

# Configuration
NAMESPACE="gitlab"
DEPLOYMENT_NAME="gitlab"
STATEFULSET_NAME="postgres"
SERVICE_NAME="gitlab-service"
POSTGRES_SERVICE="postgres"
PVC_PREFIX="gitlab"  # Matches gitlab-pvc and gitlab-backup-pvc
PV_PREFIX="gitlab"   # Matches gitlab-pv and gitlab-backup-pv
CRD_NAME="gitlabs.apps.gitlab.com"

# Function to check if resource exists
resource_exists() {
  kubectl get "$1" -n "$NAMESPACE" "$2" &> /dev/null
}

# 1. Delete Deployment
echo "Deleting GitLab Deployment..."
kubectl delete deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" --ignore-not-found

# 2. Delete StatefulSet
echo "Deleting PostgreSQL StatefulSet..."
kubectl delete statefulset "$STATEFULSET_NAME" -n "$NAMESPACE" --ignore-not-found

# 3. Delete Services
echo "Deleting Services..."
kubectl delete service "$SERVICE_NAME" -n "$NAMESPACE" --ignore-not-found
kubectl delete service "$POSTGRES_SERVICE" -n "$NAMESPACE" --ignore-not-found

# 4. Delete PVCs
echo "Deleting PersistentVolumeClaims..."
for pvc in $(kubectl get pvc -n "$NAMESPACE" --no-headers | awk '{print $1}'); do
  if [[ "$pvc" == *"$PVC_PREFIX"* ]] || [[ "$pvc" == "postgres-storage-postgres-0" ]]; then
    kubectl delete pvc "$pvc" -n "$NAMESPACE" --ignore-not-found
  fi
done

# 5. Delete PVs
echo "Deleting PersistentVolumes..."
for pv in $(kubectl get pv --no-headers | awk '{print $1}'); do
  if [[ "$pv" == *"$PV_PREFIX"* ]]; then
    kubectl delete pv "$pv" --ignore-not-found
  fi
done

# 6. Delete ConfigMap and Secret
echo "Deleting ConfigMap and Secret..."
kubectl delete configmap gitlab-config -n "$NAMESPACE" --ignore-not-found
kubectl delete secret postgres-secret -n "$NAMESPACE" --ignore-not-found

# 7. Delete Custom Resource Definition (if exists)
if resource_exists crd "$CRD_NAME"; then
  echo "Deleting Custom Resource Definition..."
  kubectl delete crd "$CRD_NAME" --ignore-not-found
fi

# 8. Delete RBAC resources
echo "Deleting RBAC resources..."
kubectl delete rolebinding gitlab-app-rolebinding-nonroot -n "$NAMESPACE" --ignore-not-found
kubectl delete clusterrole gitlab-app-role-nonroot --ignore-not-found
kubectl delete serviceaccount gitlab-app-nonroot -n "$NAMESPACE" --ignore-not-found

# 9. Delete Namespace (with finalizer cleanup if needed)
echo "Deleting Namespace..."
NS_STATUS=$(kubectl get ns "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")

if [[ "$NS_STATUS" == "Terminating" ]]; then
  echo "Namespace is stuck in Terminating state. Force deleting..."
  kubectl get namespace "$NAMESPACE" -o json | \
    jq 'del(.spec.finalizers[])' | \
    kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -
elif [[ "$NS_STATUS" != "NotFound" ]]; then
  kubectl delete ns "$NAMESPACE" --ignore-not-found
fi

# 10. Verify cleanup
echo -e "\nVerification:"
echo "Pods:"
kubectl get pods -n "$NAMESPACE" 2>/dev/null || echo "No pods found in $NAMESPACE"
echo -e "\nPersistentVolumeClaims:"
kubectl get pvc -n "$NAMESPACE" 2>/dev/null || echo "No PVCs found in $NAMESPACE"
echo -e "\nPersistentVolumes:"
kubectl get pv | grep "$PV_PREFIX" || echo "No matching PVs found"
echo -e "\nNamespace Status:"
kubectl get ns "$NAMESPACE" 2>/dev/null || echo "Namespace $NAMESPACE not found"

echo -e "\nGitLab cleanup completed successfully!"
