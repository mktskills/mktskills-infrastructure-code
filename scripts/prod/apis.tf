##################################################
## API Enablement — Prod stack
## APIs required for the production runtime environment.
## disable_on_destroy = false: never disable APIs on stack destroy.
##################################################

locals {
  prod_apis = toset([
    "run.googleapis.com",              # Cloud Run (backend API server)
    "compute.googleapis.com",          # Compute (LB, CDN, SSL, IPs)
    "secretmanager.googleapis.com",    # Secret Manager (credentials store)
    "iam.googleapis.com",              # Service account management
    "iamcredentials.googleapis.com",   # SA impersonation / workload identity
    "iap.googleapis.com",              # OAuth consent screen
    "people.googleapis.com",           # Google user info (OAuth)
    "googleads.googleapis.com",        # Google Ads API
    "analyticsadmin.googleapis.com",   # GA4 Admin API
    "analyticsdata.googleapis.com",    # GA4 Data API
    "logging.googleapis.com",          # Cloud Logging
    "monitoring.googleapis.com",       # Cloud Monitoring
    "cloudtrace.googleapis.com",       # Cloud Trace
  ])
}

resource "google_project_service" "prod_apis" {
  for_each = local.prod_apis
  provider = google
  project  = local.project_id
  service  = each.value

  disable_on_destroy = false
}
