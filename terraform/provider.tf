provider "google" {
  credentials = file(var.credentials_path) # Path to your service account JSON key
  project     = var.project_id
  region      = var.region
}
