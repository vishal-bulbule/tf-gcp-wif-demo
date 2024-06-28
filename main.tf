resource "google_storage_bucket" "my-bucket" {
  name          = "bkt-demo-000"
  location      = "us-central1"
  project = "tt-dev-001"
  force_destroy = true
  public_access_prevention = "enforced"
}
