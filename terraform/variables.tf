#provider
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster"
  type        = string
  default     = "us-central1" # Adjust if needed
}

variable "credentials_path" {
  description = "The path to the Google Cloud service account credentials JSON"
  type        = string
}

#cluster config
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "my-gke-cluster"
}

variable "node_pool_name" {
  description = "The name of the managed node pool"
  type        = string
  default     = "primary-node-pool"
}

variable "machine_type" {
  description = "The machine type for the node pool"
  type        = string
  default     = "e2-standard-4" # 4vCPUs, 16GB RAM
}

variable "min_node_count" {
  description = "The minimum number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "The maximum number of nodes in the node pool"
  type        = number
  default     = 5
}

variable "zone" {
  description = "The GCP zone where the cluster is located"
  type        = string
  default     = "us-central1-a" # Adjust if needed
}
