terraform {
  backend "gcs" {
    bucket = "csbuck-mktskills-infrastructure-tfstate"
    prefix = "devstage/"
  }
}

provider "google" {
  project = local.project_id_devstage
  region  = local.env_main_region
}

provider "google-beta" {
  project = local.project_id_devstage
  region  = local.env_main_region
}

##################################################
## Locals
##################################################

locals {
  project_id_devstage = "mktskills-prod" # Will become mktskills-devstage when projects are split
  project_folder_code = "mktskills"
  env                 = "dev"
  env_main_region     = "us-central1"
  dns_zone_project_id = "mktskills-prod" # DNS zone lives in the cross/prod project
}

##################################################
## Modules
##################################################

module "devstage_cdn" {
  source = "./cdn_websites"
  providers = {
    google      = google
    google-beta = google-beta
  }

  project_id          = local.project_id_devstage
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  dns_zone_project_id = local.dns_zone_project_id
}

module "devstage_lb" {
  source = "./lb_backends"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id          = local.project_id_devstage
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  dns_zone_project_id = local.dns_zone_project_id
}

module "devstage_iam" {
  source = "./iam"
  providers = {
    google = google
  }
  project_id          = local.project_id_devstage
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
}

module "devstage_secrets" {
  source = "./secrets"
  providers = {
    google = google
  }
  project_id          = local.project_id_devstage
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region

  service_account_backend_apiserver_email = module.devstage_iam.service_account_backend_apiserver_email

  depends_on = [module.devstage_iam]
}
