resource "google_container_cluster" "primary" {
  name                = var.cluster_name
  location            = var.zone
  deletion_protection = false

  initial_node_count       = 1    # GKE control plane node count
  remove_default_node_pool = true # We're using a custom node pool
}

resource "google_container_node_pool" "primary_pool" {
  name     = var.node_pool_name
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    disk_size_gb = 10

    # Optional: You can enable preemptible VMs here
    preemptible = false

    tags = ["gke-cluster"] # Assign the network tag for firewall rules
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}
