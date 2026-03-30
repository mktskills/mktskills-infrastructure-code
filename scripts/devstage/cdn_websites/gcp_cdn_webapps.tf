##################################################
## CDN Websites — Web App (Astro + Vite SPA) — Dev
##################################################

locals {
  # Hardcoded token that makes dev subdomains non-guessable.
  # Must match the literal in cross/build_tools/gcp_pipelines_web.tf and devstage/lb_backends.
  dev_subdomain_token = "o8styhv7948sg53i"
}

module "platform_web_app_dev" {
  source = "../../../modules/gcp_cdn_website"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id_devstage

  website_id                  = "${local.project_folder_code}-webapp-website-dev"
  bucket_location             = local.env_main_region
  subdomains                  = ["www-${local.dev_subdomain_token}"]
  full_domains                = ["www-${local.dev_subdomain_token}.mktskills.ai"]
  dns_managed_zone_name       = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id

  # SPA fallback: LB intercepts 4xx from GCS and serves app/index.html with 200.
  spa_fallback_path = "/app/index.html"
  not_found_page    = "404.html"

  cdn_policy = {
    max_ttl     = 60
    default_ttl = 60
    client_ttl  = 60
  }
}
