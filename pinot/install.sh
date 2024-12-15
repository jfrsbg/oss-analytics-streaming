#!/bin/bash

# Set variables
NAMESPACE="pinot"
RELEASE_NAME="pinot"
HELM_REPO_NAME="pinot"
HELM_REPO_URL="https://raw.githubusercontent.com/apache/pinot/refs/tags/release-1.1.0/helm/"
STORAGE_CLASS="standard"
CPU_REQUEST="500m"
MEMORY_REQUEST="1Gi"

# Create Kubernetes namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
  echo "Creating namespace: $NAMESPACE"
  kubectl create namespace $NAMESPACE
else
  echo "Namespace $NAMESPACE already exists."
fi

# Add Helm repository
if ! helm repo list | grep -q "$HELM_REPO_NAME"; then
  echo "Adding Helm repository: $HELM_REPO_NAME"
  helm repo add $HELM_REPO_NAME $HELM_REPO_URL
else
  echo "Helm repository $HELM_REPO_NAME already added."
fi

# Install or upgrade Pinot Helm chart
echo "Deploying Apache Pinot..."
helm upgrade --install $RELEASE_NAME $HELM_REPO_NAME/$RELEASE_NAME \
  -n $NAMESPACE \
  --set cluster.name=$RELEASE_NAME \
  --set server.replicaCount=3 \
  --set controller.persistence.storageClass=$STORAGE_CLASS \
  --set server.persistence.storageClass=$STORAGE_CLASS \
  --set broker.resources.requests.cpu=$CPU_REQUEST \
  --set broker.resources.requests.memory=$MEMORY_REQUEST \
  --set server.resources.requests.cpu=$CPU_REQUEST \
  --set server.resources.requests.memory=$MEMORY_REQUEST \
  --set controller.resources.cpu=$CPU_REQUEST \
  --set controller.resources.memory=$MEMORY_REQUEST

# Confirm deployment success
if kubectl get pods -n $NAMESPACE | grep -q "$RELEASE_NAME"; then
  echo "Apache Pinot deployed successfully in the $NAMESPACE namespace."
else
  echo "Deployment failed. Check logs for more details."
fi
