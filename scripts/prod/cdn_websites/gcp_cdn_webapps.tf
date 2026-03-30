##################################################
## CDN Websites — Web App (Astro + Vite SPA)
##################################################

module "platform_web_app_prod" {
  source = "../../../modules/gcp_cdn_website"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id

  website_id                  = "${local.project_folder_code}-webapp-website-prod"
  bucket_location             = local.env_main_region
  subdomains                  = ["www"]
  full_domains                = ["mktskills.ai", "www.mktskills.ai"]
  dns_managed_zone_name       = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id

  # SPA fallback: LB intercepts 4xx from GCS and serves app/index.html with 200.
  # This allows React Router (BrowserRouter) to handle virtual routes client-side.
  spa_fallback_path = "/app/index.html"
  not_found_page    = "404.html"

  # LLM discovery (regex route rules) requires a backend service, not a backend bucket.
  # Re-enable once the CDN origin is fronted by Cloud Run.
  enable_llm_discovery = false

  cdn_policy = {
    max_ttl     = 3600
    default_ttl = 3600
    client_ttl  = 3600
  }

  custom_response_headers = [
    "Strict-Transport-Security: max-age=31536000; includeSubDomains",
    "X-Frame-Options: SAMEORIGIN",
    "X-Content-Type-Options: nosniff",
    "Referrer-Policy: strict-origin-when-cross-origin",
    "Permissions-Policy: camera=(), microphone=(), geolocation=()",
  ]
}
