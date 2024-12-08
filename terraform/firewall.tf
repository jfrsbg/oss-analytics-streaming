resource "google_compute_firewall" "allow_nodeport" {
  name    = "allow-nodeport"
  network = "default" # Replace with your VPC network if it's not the default

  allow {
    protocol = "tcp"
    ports    = ["30761", "8080", "9092"] # NodePort exposed by the Kubernetes service
  }

  source_ranges = ["0.0.0.0/0"] # Open to the internet (use cautiously)
  target_tags   = ["gke-cluster"]    # Replace with the network tag for your GKE nodes
}
