##################################################
## CDN Websites — Web App (Astro + Vite SPA)
##################################################

module "platform_web_app_dev" {
  source = "../../../modules/gcp_cdn_website"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id

  website_id              = "${local.project_folder_code}-webapp-website-dev"
  bucket_location         = local.env_main_region
  subdomains              = ["app-dev"]
  full_domains            = ["app-dev.mktskills.ai"]
  dns_managed_zone_name   = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id

  cdn_policy = {
    max_ttl     = 60
    default_ttl = 60
    client_ttl  = 60
  }
}

module "platform_web_app_prod" {
  source = "../../../modules/gcp_cdn_website"
  providers = {
    google      = google
    google-beta = google-beta
  }
  project_id = local.project_id

  website_id              = "${local.project_folder_code}-webapp-website-prod"
  bucket_location         = local.env_main_region
  subdomains              = ["app"]
  full_domains            = ["mktskills.ai", "app.mktskills.ai"]
  dns_managed_zone_name   = "dnszone-${local.project_folder_code}-mktskillsai"
  dns_managed_zone_project_id = local.dns_zone_project_id

  enable_llm_discovery = true

  cdn_policy = {
    max_ttl     = 3600
    default_ttl = 3600
    client_ttl  = 3600
    # Include Accept in the cache key so CDN serves separate cached responses
    # for text/markdown vs text/html requests (required for content negotiation).
    cache_key_policy = [{
      include_http_headers = ["Accept"]
    }]
  }

  custom_response_headers = [
    "Strict-Transport-Security: max-age=31536000; includeSubDomains",
    "X-Frame-Options: SAMEORIGIN",
    "X-Content-Type-Options: nosniff",
    "Referrer-Policy: strict-origin-when-cross-origin",
    "Permissions-Policy: camera=(), microphone=(), geolocation=()",
  ]
}
