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
  project_id_cross    = "mktskills-prod"
  project_id_devstage = "mktskills-prod" # Will become mktskills-devstage when projects are split
  project_id_prod     = "mktskills-prod"
  project_id          = local.project_id_cross # Provider config — cross project
  project_folder_code = "mktskills"
  env                 = "cross"
  env_main_region     = "us-central1"
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
  depends_on          = [google_project_service.cross_apis]
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
  depends_on          = [google_project_service.cross_apis]
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
  depends_on          = [google_project_service.cross_apis]
}

module "cross_build" {
  source = "./build_tools"
  providers = {
    google = google
  }
  project_id             = local.project_id_cross
  project_folder_code    = local.project_folder_code
  env                    = local.env
  env_main_region        = local.env_main_region
  project_id_devstage    = local.project_id_devstage
  project_id_prod        = local.project_id_prod
  backend_artifacts_repo = module.cross_repos.backend_artifacts_repo
  web_app_repo_id        = module.cross_repos.web_app_repo_id
  backend_app_repo_id    = module.cross_repos.backend_app_repo_id
  depends_on             = [google_project_service.cross_apis]
}

module "cross_dns" {
  source = "./dns"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  depends_on          = [google_project_service.cross_apis]
}

output "dns_name_servers" {
  value       = module.cross_dns.name_servers
  description = "Delegate mktskills.ai to these name servers at your registrar after first apply."
}
