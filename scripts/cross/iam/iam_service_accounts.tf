##################################################
## Service Accounts — Cross (Build pipelines)
##################################################

# Service account for the backend Cloud Run service (prod)
module "sa_backend_apiserver_prod" {
  source = "../../../modules/gcp_iam_service_acct"
  providers = {
    google = google
  }
  project_id   = local.project_id
  account_id   = "sa-${local.project_folder_code}-backend-apiserver"
  display_name = "mktskills Backend API Server"
  description  = "Runtime service account for the backend Cloud Run service"
}
