terraform {
  backend "gcs" {
    bucket = "csbuck-mktskills-infrastructure-tfstate"
    prefix = "prod/"
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
  env                 = "prod"
  env_main_region     = "us-central1"
  dns_zone_project_id = "mktskills-prod"
}

##################################################
## Modules
##################################################

module "prod_cdn" {
  source = "./cdn_websites"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  dns_zone_project_id = local.dns_zone_project_id
  depends_on          = [google_project_service.prod_apis]
}

module "prod_lb" {
  source = "./lb_backends"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  dns_zone_project_id = local.dns_zone_project_id
  depends_on          = [google_project_service.prod_apis]
}

module "prod_iam" {
  source = "./iam"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region
  depends_on          = [google_project_service.prod_apis]
}

module "prod_secrets" {
  source = "./secrets"
  providers = {
    google = google
  }
  project_id          = local.project_id
  project_folder_code = local.project_folder_code
  env                 = local.env
  env_main_region     = local.env_main_region

  service_account_backend_apiserver_email = module.prod_iam.service_account_backend_apiserver_email

  depends_on = [google_project_service.prod_apis, module.prod_iam]
}
