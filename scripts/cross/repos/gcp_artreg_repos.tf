##################################################
## Artifact Registry — Docker images for backend
##################################################

module "backend_artifacts_repo" {
  source = "../../../modules/gcp_artreg_repo"
  providers = {
    google = google
  }
  project_id  = local.project_id
  repository_id = "aregrepo-${local.project_folder_code}-backend-cross"
  location    = local.env_main_region
  format      = "DOCKER"
  description = "Docker images for mktskills backend"
}
