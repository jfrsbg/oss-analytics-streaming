resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  initial_node_count       = 1    # GKE control plane node count
  remove_default_node_pool = true # We're using a custom node pool
}

resource "google_container_node_pool" "primary_pool" {
  name     = var.node_pool_name
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    # Optional: You can enable preemptible VMs here
    preemptible = false
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}
