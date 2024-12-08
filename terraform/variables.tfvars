#provider
project_id       = "<your_project_id>"
credentials_path = "~/Documents/oss-analytics-streaming/gcloud-credentials.json"
region           = "us-central1"

#cluster config
zone           = "us-central1-a"
min_node_count = 3
max_node_count = 5
cluster_name   = "cluster-streaming-analytics"
node_pool_name = "streaming-node-pool"
machine_type   = "e2-standard-2"