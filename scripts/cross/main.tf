terraform {
  backend "gcs" {
    bucket = "csbuck-mktskills-infrastructure-tfstate"
    prefix = "cross/"
  }
}

provider "google" {
  project = local.project_id
  region  = local.env_main_region
}

provider "google-beta" {
  project = local.project_id
  region  = local.env_main_region
}

##################################################
## Locals
##################################################

locals {
  org_id              = "mktskills.ai"
  project_id          = "mktskills-prod"
  project_folder_code = "mktskills"
  env                 = "cross"
  env_main_region     = "us-central1"

  # Single project — cross and prod are the same project
  project_id_prod = "mktskills-prod"
}

##################################################
## Modules
##################################################

module "cross_repos" {
  source = "./repos"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
}

module "cross_storage" {
  source = "./storage"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
}

module "cross_iam" {
  source = "./iam"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
}

module "cross_build" {
  source = "./build_tools"
  providers = {
    google = google
  }
  project_id              = local.project_id
  project_folder_code     = local.project_folder_code
  env                     = local.env
  env_main_region         = local.env_main_region
  project_id_prod         = local.project_id_prod
  backend_artifacts_repo  = module.cross_repos.backend_artifacts_repo
}
