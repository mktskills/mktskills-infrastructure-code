##################################################
## API Enablement — Cross stack
## APIs required for shared CI/CD infrastructure.
## disable_on_destroy = false: never disable APIs on stack destroy.
##################################################

locals {
  cross_apis = toset([
    "cloudbuild.googleapis.com",           # Cloud Build pipelines
    "artifactregistry.googleapis.com",     # Docker image registry
    "storage.googleapis.com",              # GCS (artifacts, TF state)
    "dns.googleapis.com",                  # Cloud DNS (zone management)
    "cloudresourcemanager.googleapis.com", # Required by Terraform provider
    "iamcredentials.googleapis.com",       # Workload identity / SA impersonation
    "iam.googleapis.com",                  # Service account management
    "serviceusage.googleapis.com",         # API enablement (meta)
  ])
}

resource "google_project_service" "cross_apis" {
  for_each = local.cross_apis
  provider = google
  project  = local.project_id
  service  = each.value

  disable_on_destroy = false
}
