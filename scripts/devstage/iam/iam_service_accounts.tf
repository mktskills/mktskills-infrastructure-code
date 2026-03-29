##################################################
## Service Accounts — Dev
##################################################

module "sa_backend_apiserver_dev" {
  source = "../../../modules/gcp_iam_service_acct"
  providers = {
    google = google
  }
  project_id                   = local.project_id_devstage
  service_account_name         = "${local.project_folder_code}-backend-api-dev"
  service_account_display_name = "mktskills Backend API Server (dev)"
  service_account_description  = "Runtime service account for the dev backend Cloud Run service"
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
  ]
}
