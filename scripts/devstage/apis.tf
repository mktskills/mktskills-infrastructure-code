##################################################
## API Enablement — Devstage stack
## APIs required for the dev/staging environment.
## Mirrors prod/apis.tf — update both when adding new integrations.
## disable_on_destroy = false: never disable APIs on stack destroy.
##################################################

locals {
  devstage_apis = toset([
    "run.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iap.googleapis.com",
    "people.googleapis.com",
    "googleads.googleapis.com",
    "analyticsadmin.googleapis.com",
    "analyticsdata.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
  ])
}

resource "google_project_service" "devstage_apis" {
  for_each = local.devstage_apis
  provider = google
  project  = local.project_id_devstage
  service  = each.value

  disable_on_destroy = false
}
