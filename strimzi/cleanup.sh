#!/bin/bash

# Namespaces to delete
NAMESPACES=("kafka" "kafka-operator")

# Delete resources created by the Kafka operator
RESOURCE_FILES=(
  "examples/kafka/kraft/kafka-with-dual-role-nodes.yaml"
  "examples/connect/kafka-connect.yaml"
  "examples/topic/website-events.yaml"
)

# Delete the Kafka topic, Kafka-Connect cluster, and Kafka cluster
echo "Deleting Kafka resources in kafka namespace..."
for FILE in "${RESOURCE_FILES[@]}"; do
  if kubectl delete -f $FILE -n kafka >/dev/null 2>&1; then
    echo "Deleted resource defined in $FILE."
  else
    echo "Resource in $FILE not found or already deleted."
  fi
done

# Delete the Kafka operator
echo "Deleting Kafka operator in kafka-operator namespace..."
kubectl delete -f install/cluster-operator -n kafka-operator >/dev/null 2>&1 && echo "Kafka operator deleted." || echo "Kafka operator resources not found or already deleted."

# Delete RoleBinding resources
ROLE_BINDING_FILES=(
  "install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml"
  "install/cluster-operator/023-RoleBinding-strimzi-cluster-operator.yaml"
  "install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml"
)
echo "Deleting RoleBinding resources..."
for NAMESPACE in "${NAMESPACES[@]}"; do
  for FILE in "${ROLE_BINDING_FILES[@]}"; do
    if kubectl delete -f $FILE -n $NAMESPACE >/dev/null 2>&1; then
      echo "Deleted RoleBinding resource defined in $FILE from namespace $NAMESPACE."
    else
      echo "RoleBinding resource in $FILE not found or already deleted from namespace $NAMESPACE."
    fi
  done
done

# Delete namespaces
echo "Deleting namespaces..."
for NAMESPACE in "${NAMESPACES[@]}"; do
  if kubectl delete namespace $NAMESPACE >/dev/null 2>&1; then
    echo "Namespace $NAMESPACE deleted."
  else
    echo "Namespace $NAMESPACE not found or already deleted."
  fi
done

echo "Cleanup process completed."
