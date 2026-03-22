##################################################
## Secret Manager — Prod
##################################################

# Clerk publishable key (non-sensitive, but stored for consistency)
module "secret_clerk_publishable_key" {
  source = "../../../modules/gcp_secret_manager"
  providers = {
    google = google
  }
  project_id  = local.project_id
  secret_id   = "secret-${local.project_folder_code}-clerk-publishable-key-prod"
  accessors   = ["serviceAccount:${local.service_account_backend_apiserver_email}"]
}

# Clerk secret key
module "secret_clerk_secret_key" {
  source = "../../../modules/gcp_secret_manager"
  providers = {
    google = google
  }
  project_id  = local.project_id
  secret_id   = "secret-${local.project_folder_code}-clerk-secret-key-prod"
  accessors   = ["serviceAccount:${local.service_account_backend_apiserver_email}"]
}

# Database connection string (add as needed)
module "secret_db_url" {
  source = "../../../modules/gcp_secret_manager"
  providers = {
    google = google
  }
  project_id  = local.project_id
  secret_id   = "secret-${local.project_folder_code}-db-url-prod"
  accessors   = ["serviceAccount:${local.service_account_backend_apiserver_email}"]
}
