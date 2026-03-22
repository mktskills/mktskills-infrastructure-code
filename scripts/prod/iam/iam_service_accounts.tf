##################################################
## Service Accounts — Prod
##################################################

module "sa_backend_apiserver" {
  source = "../../../modules/gcp_iam_service_acct"
  providers = {
    google = google
  }
  project_id                   = local.project_id
  service_account_name         = "sa-${local.project_folder_code}-backend-apiserver"
  service_account_display_name = "mktskills Backend API Server"
  service_account_description  = "Runtime service account for the backend Cloud Run service"
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
  ]
}
