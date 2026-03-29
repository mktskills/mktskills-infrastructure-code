##################################################
## Cloud Build — GitHub repository connections
##################################################

# NOTE: GitHub connections must be authorized manually in the GCP Console
# (Cloud Build > Repositories > Connect Repository) before Terraform can
# reference them. Run terraform apply after completing the manual step.

module "repo_web_app" {
  source = "../../../modules/gcp_repository"
  providers = {
    google = google
  }
  project_id  = local.project_id
  location    = local.env_main_region
  repo_name   = "mktskills-web-app"
  github_owner           = "mktskills"
  github_repo            = "mktskills-web-app"
  github_connection_name = local.github_connection_name
}

module "repo_backend_app" {
  source = "../../../modules/gcp_repository"
  providers = {
    google = google
  }
  project_id  = local.project_id
  location    = local.env_main_region
  repo_name   = "mktskills-backend-app"
  github_owner           = "mktskills"
  github_repo            = "mktskills-backend-app"
  github_connection_name = local.github_connection_name
}
