locals {
  empty_cache_key_policy = {}

  use_dns_zone = var.dns_managed_zone_name != null
  domain_names = var.full_domains != null ? var.full_domains : [
    for subdomain in var.subdomains : 
    subdomain == "" ? trimsuffix(data.google_dns_managed_zone.cdn_dns_zone[0].dns_name, ".") :
    "${subdomain}.${trimsuffix(data.google_dns_managed_zone.cdn_dns_zone[0].dns_name, ".")}"
  ]
}

resource "google_project_service" "compute" {
  provider = google
  project  = var.project_id
  
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "website_bucket" {
  provider = google
  project  = var.project_id
  count    = var.backend_type == "BUCKET" ? 1 : 0

  name              = "csbuck-${var.website_id}"
  location          = var.bucket_location

  website {
    main_page_suffix = var.main_page
    not_found_page   = var.not_found_page
  }
}

resource "google_storage_default_object_access_control" "website_read" {
  provider = google
  count    = var.backend_type == "BUCKET" ? 1 : 0

  bucket = google_storage_bucket.website_bucket[0].name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_iam_member" "bucket_editors" {
  provider = google
  for_each = var.backend_type == "BUCKET" ? toset(var.bucket_editors) : toset([])

  bucket = google_storage_bucket.website_bucket[0].name
  role   = "roles/storage.objectAdmin"
  member = each.value
}

resource "google_compute_global_address" "cdn_ip" {
  provider = google
  project  = var.project_id

  name = "cptip-${var.website_id}"
}

data "google_dns_managed_zone" "cdn_dns_zone" {
  count    = local.use_dns_zone ? 1 : 0
  provider = google
  project  = var.dns_managed_zone_project_id != null ? var.dns_managed_zone_project_id : var.project_id
  name     = var.dns_managed_zone_name
}

resource "google_dns_record_set" "cdn_dns_records" {
  provider = google
  for_each = toset(local.use_dns_zone ? local.domain_names : [])
  project  = var.dns_managed_zone_project_id != null ? var.dns_managed_zone_project_id : var.project_id

  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone_name
  rrdatas      = [google_compute_global_address.cdn_ip.address]

  depends_on = [google_compute_global_address.cdn_ip]
}

resource "google_compute_managed_ssl_certificate" "cdn_certificate" {
  count    = var.custom_ssl_certificate == null && length(local.domain_names) > 0 ? 1 : 0
  provider = google-beta
  project  = var.project_id

  name     = "cptcert-${var.website_id}"
  type     = "MANAGED"
  managed {
    domains = local.domain_names
  }
}

resource "google_compute_backend_bucket" "cdn_backend" {
  count    = var.backend_type == "BUCKET" ? 1 : 0
  provider = google
  project  = var.project_id

  name        = "cdnback-${var.website_id}"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website_bucket[0].name
  enable_cdn  = true

  dynamic "cdn_policy" {
    for_each = var.cdn_policy != null ? [var.cdn_policy] : []
    content {
      cache_mode                         = lookup(cdn_policy.value, "cache_mode", null)
      serve_while_stale                  = lookup(cdn_policy.value, "serve_while_stale", null)
      request_coalescing                 = lookup(cdn_policy.value, "request_coalescing", null) != false
      signed_url_cache_max_age_sec       = coalesce(lookup(cdn_policy.value, "signed_url_cache_max_age_sec", null), 0)
      default_ttl                        = lookup(cdn_policy.value, "default_ttl", null)
      negative_caching                   = lookup(cdn_policy.value, "negative_caching", null)
      max_ttl                            = lookup(cdn_policy.value, "max_ttl", null)
      client_ttl                         = lookup(cdn_policy.value, "client_ttl", null)

      dynamic "bypass_cache_on_request_headers" {
        for_each = cdn_policy.value.bypass_cache_on_request_headers != null ? cdn_policy.value.bypass_cache_on_request_headers : []
        content {
          header_name = bypass_cache_on_request_headers.value.header_name
        }
      }

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? cdn_policy.value.cache_key_policy : []
        content {
          query_string_whitelist = lookup(cache_key_policy.value, "query_string_whitelist", null)
          include_http_headers   = lookup(cache_key_policy.value, "include_http_headers", null)
        }
      }

      dynamic "negative_caching_policy" {
        for_each = cdn_policy.value.negative_caching_policy != null ? [cdn_policy.value.negative_caching_policy] : []
        content {
          code = lookup(negative_caching_policy.value, "code", null)
          ttl  = lookup(negative_caching_policy.value, "ttl", null)
        }
      }
    }
  }

  compression_mode      = var.compression_mode
  edge_security_policy  = var.edge_security_policy

  custom_response_headers = var.custom_response_headers
}

resource "google_compute_backend_service" "cdn_backend_external" {
  count    = var.backend_type == "EXTERNAL_URL" ? 1 : 0
  provider = google
  project  = var.project_id

  name        = "cdnback-${var.website_id}"
  description = "External URL backend for the website"
  enable_cdn  = true

  custom_request_headers = var.custom_request_headers
  custom_response_headers = var.custom_response_headers

  backend {
    group = google_compute_global_network_endpoint_group.external_backend[0].self_link
  }

  dynamic "cdn_policy" {
    for_each = var.cdn_policy != null ? [var.cdn_policy] : []
    content {
      cache_mode                         = lookup(cdn_policy.value, "cache_mode", null)
      serve_while_stale                  = lookup(cdn_policy.value, "serve_while_stale", null)
      signed_url_cache_max_age_sec       = coalesce(lookup(cdn_policy.value, "signed_url_cache_max_age_sec", null), 0)
      default_ttl                        = lookup(cdn_policy.value, "default_ttl", null)
      negative_caching                   = lookup(cdn_policy.value, "negative_caching", null)
      max_ttl                            = lookup(cdn_policy.value, "max_ttl", null)
      client_ttl                         = lookup(cdn_policy.value, "client_ttl", null)

      dynamic "bypass_cache_on_request_headers" {
        for_each = cdn_policy.value.bypass_cache_on_request_headers != null ? cdn_policy.value.bypass_cache_on_request_headers : []
        content {
          header_name = bypass_cache_on_request_headers.value.header_name
        }
      }

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_host           = lookup(cache_key_policy.value, "include_host", true)
          include_protocol       = lookup(cache_key_policy.value, "include_protocol", true)
          include_query_string   = lookup(cache_key_policy.value, "include_query_string", true)
          query_string_whitelist = lookup(cache_key_policy.value, "query_string_whitelist", null)
          include_http_headers   = lookup(cache_key_policy.value, "include_http_headers", null)
          include_named_cookies  = lookup(cache_key_policy.value, "include_named_cookies", null)
        }
      }

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy == null ? [1] : []
        content {
          include_host           = true
          include_protocol       = true
          include_query_string   = true
        }
      }

      dynamic "negative_caching_policy" {
        for_each = cdn_policy.value.negative_caching_policy != null ? cdn_policy.value.negative_caching_policy : []
        content {
          code = lookup(negative_caching_policy.value, "code", null)
          ttl  = lookup(negative_caching_policy.value, "ttl", null)
        }
      }
    }
  }

  protocol = var.external_url != null ? (can(regex("^https://", var.external_url)) ? "HTTPS" : "HTTP") : "HTTP"
}

resource "google_compute_global_network_endpoint_group" "external_backend" {
  count    = var.backend_type == "EXTERNAL_URL" ? 1 : 0
  provider = google
  project  = var.project_id

  name                  = "neg-${var.website_id}"
  network_endpoint_type = "INTERNET_FQDN_PORT"
  default_port          = "443"
}

resource "google_compute_global_network_endpoint" "external_backend" {
  count    = var.backend_type == "EXTERNAL_URL" ? 1 : 0
  provider = google
  project  = var.project_id

  global_network_endpoint_group = google_compute_global_network_endpoint_group.external_backend[0].name
  fqdn                          = var.external_url != null ? trim(split("://", var.external_url)[1], "/") : ""
  port                          = 443
}

resource "google_compute_url_map" "cdn_map_https" {
  provider = google
  project  = var.project_id

  name            = "cptumaps-${var.website_id}"
  default_service = var.backend_type == "BUCKET" ? google_compute_backend_bucket.cdn_backend[0].id : (
    var.backend_type == "EXTERNAL_URL" ? google_compute_backend_service.cdn_backend_external[0].id : null
  )

  dynamic "default_url_redirect" {
    for_each = var.backend_type != "BUCKET" && var.backend_type != "EXTERNAL_URL" ? [1] : []
    content {
        host_redirect          = var.external_url != null ? trim(split("://", var.external_url)[1], "/") : ""
        https_redirect         = var.external_url != null ? split("://", var.external_url)[0] == "https" : true
        path_redirect          = "/"
        redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
        strip_query            = false
      }
  }

  dynamic "test" {
    for_each = var.backend_type == "BUCKET" || var.backend_type == "EXTERNAL_URL" ? [1] : []
    content {
      host    = "https://${length(local.domain_names) > 0 ? local.domain_names[0] : "example.com"}"
      path    = "/"
      service = var.backend_type == "BUCKET" ? google_compute_backend_bucket.cdn_backend[0].id : google_compute_backend_service.cdn_backend_external[0].id
    }
  }
}

resource "google_compute_url_map" "cdn_map_http" {
  provider = google
  project  = var.project_id

  name = "cptumap-${var.website_id}"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
    prefix_redirect = ""
  }
}

resource "google_compute_target_https_proxy" "cdn_target_proxy_https" {
  provider = google
  project  = var.project_id

  name             = "cpttspxy-${var.website_id}"
  url_map          = google_compute_url_map.cdn_map_https.self_link
  ssl_certificates = var.custom_ssl_certificate != null ? [var.custom_ssl_certificate] : [google_compute_managed_ssl_certificate.cdn_certificate[0].self_link]
  ssl_policy       = google_compute_ssl_policy.cdn_ssl_policy.self_link
}

resource "google_compute_ssl_policy" "cdn_ssl_policy" {
  name            = "cpttspxy-${var.website_id}"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_target_http_proxy" "cdn_target_proxy_http" {
  provider = google
  project  = var.project_id

  name             = "cpttpxy-${var.website_id}"
  url_map          = google_compute_url_map.cdn_map_http.self_link
}

resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule_https" {
  provider = google
  project  = var.project_id

  name                  = "cptfruls-${var.website_id}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.cdn_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.cdn_target_proxy_https.self_link
}

resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule_http" {
  provider = google
  project  = var.project_id

  name                  = "cptfrul-${var.website_id}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.cdn_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.cdn_target_proxy_http.self_link
}