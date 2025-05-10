#!/bin/bash

# Create output directory with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="k8s-resources-$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

# Function to extract related resources
extract_related_resources() {
  local namespace=$1
  local resource_type=$2
  local resource_name=$3
  
  # Create directory for this resource
  RESOURCE_DIR="$OUTPUT_DIR/$namespace/$resource_type-$resource_name"
  mkdir -p "$RESOURCE_DIR"
  
  echo "Processing $namespace/$resource_type/$resource_name"
  
  # Extract main resource
  kubectl get "$resource_type" -n "$namespace" "$resource_name" -o yaml > "$RESOURCE_DIR/${resource_type}.yaml"
  
  # Get the selector labels
  selector=$(kubectl get "$resource_type" -n "$namespace" "$resource_name" -o jsonpath='{.spec.selector.matchLabels}' 2>/dev/null | tr -d '{}"' | tr ':' '=')
  
  # If no selector.matchLabels, try .spec.selector
  if [ -z "$selector" ]; then
    selector=$(kubectl get "$resource_type" -n "$namespace" "$resource_name" -o jsonpath='{.spec.selector}' 2>/dev/null | tr -d '{}"' | tr ':' '=')
  fi

  # If we have a selector, use it to find related resources
  if [ -n "$selector" ]; then
    # Core resources
    kubectl get service -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/service.yaml" 2>/dev/null
    kubectl get configmap -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/configmap.yaml" 2>/dev/null
    kubectl get secret -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/secret.yaml" 2>/dev/null
    kubectl get pvc -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/pvc.yaml" 2>/dev/null
    
    # Network-related
    kubectl get ingress -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/ingress.yaml" 2>/dev/null
    kubectl get networkpolicy -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/networkpolicy.yaml" 2>/dev/null
    
    # Scaling/management
    kubectl get hpa -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/hpa.yaml" 2>/dev/null
    kubectl get poddisruptionbudget -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/pdb.yaml" 2>/dev/null
    
    # Workloads
    kubectl get replicaset -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/replicaset.yaml" 2>/dev/null
    kubectl get pod -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/pod.yaml" 2>/dev/null
    
    # RBAC
    kubectl get role -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/role.yaml" 2>/dev/null
    kubectl get rolebinding -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/rolebinding.yaml" 2>/dev/null
    kubectl get serviceaccount -n "$namespace" --selector="$selector" -o yaml > "$RESOURCE_DIR/serviceaccount.yaml" 2>/dev/null
  fi
  
  # Special handling for PV (regardless of selector)
  pvc_name=$(kubectl get pvc -n "$namespace" --selector="$selector" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  if [ -n "$pvc_name" ]; then
    pv_name=$(kubectl get pvc -n "$namespace" "$pvc_name" -o jsonpath='{.spec.volumeName}')
    kubectl get pv "$pv_name" -o yaml > "$RESOURCE_DIR/pv.yaml" 2>/dev/null
  fi
}

# Process standard workload resources
process_workloads() {
  # Deployments
  kubectl get deployments -A --no-headers | while read -r namespace deployment rest; do
    extract_related_resources "$namespace" "deployment" "$deployment"
  done

  # StatefulSets
  kubectl get statefulsets -A --no-headers | while read -r namespace statefulset rest; do
    extract_related_resources "$namespace" "statefulset" "$statefulset"
  done

  # DaemonSets
  kubectl get daemonsets -A --no-headers | while read -r namespace daemonset rest; do
    extract_related_resources "$namespace" "daemonset" "$daemonset"
  done

  # Jobs
  kubectl get jobs -A --no-headers | while read -r namespace job rest; do
    extract_related_resources "$namespace" "job" "$job"
  done

  # CronJobs
  kubectl get cronjobs -A --no-headers | while read -r namespace cronjob rest; do
    extract_related_resources "$namespace" "cronjob" "$cronjob"
  done
}

# Process cluster-wide resources
process_cluster_resources() {
  CLUSTER_DIR="$OUTPUT_DIR/cluster-resources"
  mkdir -p "$CLUSTER_DIR"
  
  # PersistentVolumes (not namespaced)
  kubectl get pv -o yaml > "$CLUSTER_DIR/persistentvolumes.yaml" 2>/dev/null
  
  # StorageClasses
  kubectl get storageclass -o yaml > "$CLUSTER_DIR/storageclasses.yaml" 2>/dev/null
  
  # ClusterRoles
  kubectl get clusterrole -o yaml > "$CLUSTER_DIR/clusterroles.yaml" 2>/dev/null
  
  # ClusterRoleBindings
  kubectl get clusterrolebinding -o yaml > "$CLUSTER_DIR/clusterrolebindings.yaml" 2>/dev/null
  
  # Namespaces
  kubectl get namespace -o yaml > "$CLUSTER_DIR/namespaces.yaml" 2>/dev/null
}

# Main execution
process_workloads
process_cluster_resources

echo "Extraction complete. Resources saved in $OUTPUT_DIR"
echo "Cluster-wide resources are in $OUTPUT_DIR/cluster-resources/"
