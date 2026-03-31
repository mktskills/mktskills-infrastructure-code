##################################################
## Secret Manager — Prod
## Each secret stores a JSON object — see keys in comments.
##################################################

locals {
  _sa = ["serviceAccount:${local.service_account_backend_apiserver_email}"]
}

# {"PUBLISHABLE_KEY": "...", "SECRET_KEY": "..."}
module "secret_clerk" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-clerk-prod"
  read_principals = local._sa
}

# {"URL": "postgresql+asyncpg://..."}
module "secret_db" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-db-prod"
  read_principals = local._sa
}

# {"JWT_SECRET": "...", "OAUTH_STATE_SECRET": "...", "TOKEN_ENCRYPTION_KEY": "..."}
module "secret_session" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-session-prod"
  read_principals = local._sa
}

# {"ANTHROPIC_API_KEY": "...", "OPENROUTER_API_KEY": "...", ...}
module "secret_aimodels" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-aimodels-prod"
  read_principals = local._sa
}

# {"GOOGLE_CLIENT_ID": "...", "GOOGLE_CLIENT_SECRET": "...", "GOOGLE_ADS_DEVELOPER_TOKEN": "...", "META_APP_ID": "...", "META_APP_SECRET": "..."}
module "secret_integrations" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-integrations-prod"
  read_principals = local._sa
}

# {"API_KEY": "..."}  — Daytona sandbox runtime
module "secret_daytona" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-daytona-prod"
  read_principals = local._sa
}

# {"RESEND_API_KEY": "..."}  — Messaging services (Resend, future: Twilio, etc.)
module "secret_messaging" {
  source          = "../../../modules/gcp_secret_manager"
  providers       = { google = google }
  project_id      = local.project_id
  secret_id       = "secret-${local.project_folder_code}-messaging-prod"
  read_principals = local._sa
}
