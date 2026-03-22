##################################################
## Secret Manager — Prod
##################################################

locals {
  _sa = ["serviceAccount:${local.service_account_backend_apiserver_email}"]
}

# Clerk publishable key (non-sensitive, but stored for consistency)
module "secret_clerk_publishable_key" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-clerk-publishable-key-prod"
  read_principals = local._sa
}

# Clerk secret key (used for invitations API)
module "secret_clerk_secret_key" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-clerk-secret-key-prod"
  read_principals = local._sa
}

# Database connection string
module "secret_db_url" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-db-url-prod"
  read_principals = local._sa
}

# Session JWT signing secret
module "secret_session_jwt_secret" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-session-jwt-secret-prod"
  read_principals = local._sa
}

# OAuth state signing secret
module "secret_oauth_state_secret" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-oauth-state-secret-prod"
  read_principals = local._sa
}

# Meta Ads app credentials
module "secret_meta_app_id" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-meta-app-id-prod"
  read_principals = local._sa
}

module "secret_meta_app_secret" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-meta-app-secret-prod"
  read_principals = local._sa
}

# Google OAuth credentials (shared by Google Ads + GA4)
module "secret_google_client_id" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-google-client-id-prod"
  read_principals = local._sa
}

module "secret_google_client_secret" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-google-client-secret-prod"
  read_principals = local._sa
}

module "secret_google_ads_developer_token" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-google-ads-developer-token-prod"
  read_principals = local._sa
}

# Daytona sandbox API key (optional — skills disabled without it)
module "secret_daytona_api_key" {
  source = "../../../modules/gcp_secret_manager"
  providers = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-daytona-api-key-prod"
  read_principals = local._sa
}
