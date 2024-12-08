# oss-analytics-streaming
Repository aims to deliver a fully open-source streaming data platform. The following image is what we're going to achive with this repository. This is a W.I.P. 

![Real time analytics](images/platform.png)

# Pre requisites
- Understanding of Kubernetes
- Understanding of kakfa ecosystem
- Minkube
- Kubectl
- Kubens
- kubernetes 1.25+
- Strimzi kafka
- terraform 1.10+

# Installing components

## Deploying a Kubernetes Cluster on Google Cloud (GKE)

Replace the values according to your own account and project. 

Make sure the role provisioning the resources have the following permissions:
- roles/container.admin
- roles/compute.networkAdmin
- roles/iam.serviceAccountUser
- compute.firewalls.create
- compute.firewalls.update

```sh 
terraform init
terraform apply -var-file=variables.tfvars --auto-approve
```

Wait until the cluster is created

## Connect to GCP and configure kubectl

```sh 
gcloud auth login
```

```sh 
gcloud config set project <your-project-name>
```

```sh 
gcloud container clusters get-credentials cluster-streaming-analytics \
    --region=us-central1-a
```

## Strimzi Kafka

Following strimzi best practices, it is recommended to deploy the operator and other kafka components (kafka connect, kafka cluster) into different namespaces. Here we're going to create 2 namespaces:

```sh 
kubectl create namespace kafka -> where our kafka components will be deployed

kubectl create namespace kafka-operator -> where kafka operator will be deployed
```

Select the namespace to deploy the strimzi operator
```sh 
kubens kafka-operator
```

We have to make sure the operator will watch kafka and kafka-operator namespace. That's why we have to install the RoleBindings for both kafka and kafka-operator namespaces:

```sh 
kubectl create -f strimzi/install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n <namespace>

kubectl create -f strimzi/install/cluster-operator/023-RoleBinding-strimzi-cluster-operator.yaml -n <namespace>

kubectl create -f strimzi/install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n <namespace>
```

Now it's time to deploy the CRDs and the operator

```sh 
kubectl create -f strimzi/install/cluster-operator -n kafka-operator
```

Now that strimzi operator is configured, it's time to deploy our kafka cluster, topic operator and user operator. Deploying kafka cluster in Kraft mode is the modern way to manage a fresh kafka cluster, and we're going to deploy it that way

Apply the configuration

```sh 
kubectl apply -f strimzi/examples/kafka/kraft/kafka-with-dual-role-nodes.yaml -n kafka
```

Install kafka connect

```sh 
kubectl apply -f strimzi/examples/connect/kafka-connect.yaml -n kafka
```


create a topic using the kafka operator

```sh 
kubectl apply -f strimzi/examples/topic/website-events.yaml -n kafka
```

# Running the Python Producer

Install poetry

```sh 
pip install poetry
```

Install the project

```sh 
cd python-kafka-producer
poetry install
```

Activate the virtual env
```sh 
source .venv/bin/activate
```

Port-forward your cluster service
```sh 
kubectl port-forward service/kafka-cluster-kafka-plain-bootstrap 9092:9092
```

Test your python producer
```sh 
python producer.py
```

Verrify if your consumer can get the messages
```sh 
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic website-events --from-beginning
```

# Deploying Apache Pinot

Create a new Namespace
```sh 
kubectl create ns pinot
```

Add the repo
```sh 
helm repo add pinot https://raw.githubusercontent.com/apache/pinot/master/helm
```
