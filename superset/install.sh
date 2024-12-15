#!/bin/bash
# Set variables
NAMESPACE="superset"
RELEASE_NAME="superset"
HELM_REPO_NAME="superset"
HELM_REPO_URL="https://apache.github.io/superset"
VALUES_FILE="values.yaml"

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


helm upgrade --install $RELEASE_NAME $HELM_REPO_NAME/$RELEASE_NAME \
  -n $NAMESPACE \
  --values $VALUES_FILE