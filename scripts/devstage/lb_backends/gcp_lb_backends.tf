##################################################
## Load Balancer Backends — API (Cloud Run) — Dev
##################################################

locals {
  # Hardcoded token that makes dev subdomains non-guessable.
  # Must match the literal in cross/build_tools/gcp_pipelines_web.tf and devstage/cdn_websites.
  dev_subdomain_token = "o8styhv7948sg53i"
}

module "platform_backend_api_dev" {
  source = "../../../modules/gcp_lb_backend"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id_devstage

  backend_id                  = "${local.project_folder_code}-backend-api-dev"
  subdomains                  = ["api-${local.dev_subdomain_token}"]
  dns_managed_zone_name       = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id
  serverless_backends = [{
    name           = "${local.project_folder_code}-backend-api-dev"
    region         = local.env_main_region
    cloud_run_name = "crunserv-${local.project_folder_code}-backend-api-dev"
  }]
  enable_health_check = false # Serverless NEGs do not support LB health checks; Cloud Run self-manages health
}
