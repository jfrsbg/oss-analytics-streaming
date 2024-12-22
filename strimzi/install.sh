#!/bin/bash

# Create namespaces
NAMESPACES=("kafka" "kafka-operator")
for NAMESPACE in "${NAMESPACES[@]}"; do
  if ! kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE
  else
    echo "Namespace $NAMESPACE already exists."
  fi
done

# Replace <namespace> in RoleBinding files and apply them
ROLE_BINDING_FILES=(
  "install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml"
  "install/cluster-operator/023-RoleBinding-strimzi-cluster-operator.yaml"
  "install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml"
)
for NAMESPACE in "${NAMESPACES[@]}"; do
  for FILE in "${ROLE_BINDING_FILES[@]}"; do
    echo "Applying $FILE to namespace $NAMESPACE"
    kubectl create -f $FILE -n $NAMESPACE
  done
done

# Install Kafka operator
echo "Installing Kafka operator in kafka-operator namespace"
kubectl create -f install/cluster-operator -n kafka-operator

# Wait for the cluster-operator to be running
echo "Waiting for the Kafka cluster-operator to be ready..."
while true; do
  STATUS=$(kubectl get pods -n kafka-operator -l name=strimzi-cluster-operator -o jsonpath='{.items[0].status.phase}')
  if [ "$STATUS" == "Running" ]; then
    READY_CONDITIONS=$(kubectl get pods -n kafka-operator -l name=strimzi-cluster-operator -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
    if [ "$READY_CONDITIONS" == "True" ]; then
      echo "Cluster-operator is running and ready. Proceeding with Kafka cluster deployment."
      break
    fi
  fi
  echo "Cluster-operator not ready. Retrying in 10 seconds..."
  sleep 10
done

# Deploy Kafka cluster
echo "Deploying Kafka cluster in kafka namespace"
kubectl apply -f examples/kafka/kraft/kafka-with-dual-role-nodes.yaml -n kafka

# Deploy Kafka-Connect cluster
# echo "Deploying Kafka-Connect cluster in kafka namespace"
# kubectl apply -f examples/connect/kafka-connect.yaml -n kafka

# Create a topic using the Kafka operator
echo "Creating Kafka topic in kafka namespace"
kubectl apply -f examples/topic/website-events.yaml -n kafka
