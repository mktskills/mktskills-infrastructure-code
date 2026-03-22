##################################################
## Load Balancer Backends — API (Cloud Run)
##################################################

module "platform_backend_api_dev" {
  source = "../../../modules/gcp_lb_backend"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id

  backend_id                  = "${local.project_folder_code}-backend-apiserver-dev"
  subdomains                  = ["api-dev"]
  dns_managed_zone_name       = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id
  serverless_backends = [{
    name           = "${local.project_folder_code}-backend-apiserver-dev"
    region         = local.env_main_region
    cloud_run_name = "crunserv-${local.project_folder_code}-backend-apiserver-dev"
  }]
  enable_health_check = false  # Serverless NEGs do not support LB health checks; Cloud Run self-manages health
}

module "platform_backend_api_prod" {
  source = "../../../modules/gcp_lb_backend"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id

  backend_id                  = "${local.project_folder_code}-backend-apiserver-prod"
  subdomains                  = ["api"]
  dns_managed_zone_name       = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id
  serverless_backends = [{
    name           = "${local.project_folder_code}-backend-apiserver-prod"
    region         = local.env_main_region
    cloud_run_name = "crunserv-${local.project_folder_code}-backend-apiserver-prod"
  }]
  enable_health_check = false  # Serverless NEGs do not support LB health checks; Cloud Run self-manages health
}
