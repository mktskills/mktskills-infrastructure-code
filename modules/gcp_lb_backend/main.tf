resource "google_project_service" "compute" {
  provider = google
  project  = var.project_id
  
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "lb_ip" {
  provider = google
  project  = var.project_id

  name = "cptip-${var.backend_id}"
}

data "google_dns_managed_zone" "lb_dns_zone" {
  provider = google
  project  = var.dns_managed_zone_project_id != null ? var.dns_managed_zone_project_id : var.project_id

  name = var.dns_managed_zone_name
}

resource "google_dns_record_set" "lb_dns_records" {
  provider = google
  for_each = toset(var.subdomains)
  project  = var.dns_managed_zone_project_id != null ? var.dns_managed_zone_project_id : var.project_id

  name         = "${each.value}.${data.google_dns_managed_zone.lb_dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone_name
  rrdatas      = [google_compute_global_address.lb_ip.address]

  depends_on = [google_compute_global_address.lb_ip]
}

resource "google_compute_managed_ssl_certificate" "lb_certificate" {
  provider = google-beta
  project  = var.project_id

  name     = "cptcert-${var.backend_id}"
  type     = "MANAGED"
  managed {
    domains = [for dns_record in google_dns_record_set.lb_dns_records : dns_record.name]
  }
}

resource "google_compute_region_network_endpoint_group" "lb_serverless_neg" {
  provider = google-beta
  project  = var.project_id
  for_each = { for serverless_backend in var.serverless_backends: "${serverless_backend.name}-${serverless_backend.region}" => serverless_backend }

  name                  = "cptneg-${each.value.name}"
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  dynamic "cloud_function" {
    for_each = each.value.cloud_function_name != null ? [each.value] : []
    content {
      function = each.value.cloud_function_name
    }
  }

  dynamic "cloud_run" {
    for_each = each.value.cloud_run_name != null ? [each.value] : []
    content {
      service = each.value.cloud_run_name
    }
  }

  dynamic "app_engine" {
    for_each = each.value.appengine_service != null ? [each.value] : []
    content {
      service = each.value.appengine_service
      version = each.value.appengine_version_id
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "lb_health_check" {
  count   = var.enable_health_check ? 1 : 0
  project = var.project_id
  name    = "cpthc-${var.backend_id}"

  http_health_check {
    port               = var.health_check_port
    request_path       = var.health_check_path
    proxy_header       = var.health_check_proxy_header
    response           = var.health_check_response
    port_specification = var.health_check_port_specification
  }

  check_interval_sec  = var.health_check_interval_sec
  timeout_sec        = var.health_check_timeout_sec
  healthy_threshold  = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold
}

resource "google_compute_backend_service" "lb_backend" {
  provider = google
  project  = var.project_id

  name          = "cptback-${var.backend_id}"
  protocol      = "HTTP2"

  dynamic "backend" {
    for_each = {
      for k, v in google_compute_region_network_endpoint_group.lb_serverless_neg : k => v
    } 
    content {
      group = backend.value.id
    }
  }

  security_policy = var.security_policy
  
  health_checks = var.enable_health_check ? [google_compute_health_check.lb_health_check[0].id] : null
}

resource "google_compute_url_map" "lb_map_https" {
  provider = google
  project  = var.project_id

  name            = "cptumaps-${var.backend_id}"
  default_service = google_compute_backend_service.lb_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "pathmatcher"
  }

  path_matcher {
    name = "pathmatcher"

    default_service = google_compute_backend_service.lb_backend.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.lb_backend.id
    }
  }

  test {
    host = "https://${var.subdomains[0]}.${trimsuffix(data.google_dns_managed_zone.lb_dns_zone.dns_name, ".")}"
    path = "/"
    service = google_compute_backend_service.lb_backend.id
  }
}

resource "google_compute_target_https_proxy" "lb_target_proxy_https" {
  provider = google
  project  = var.project_id

  name             = "cpttspxy-${var.backend_id}"
  url_map          = google_compute_url_map.lb_map_https.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_certificate.self_link]
  ssl_policy       = google_compute_ssl_policy.lb_ssl_policy.self_link
}

resource "google_compute_ssl_policy" "lb_ssl_policy" {
  provider = google
  project  = var.project_id

  name            = "cptsslp-${var.backend_id}"
  profile         = "MODERN"
  min_tls_version = var.min_tls_version
}

resource "google_compute_global_forwarding_rule" "lb_forwarding_rule_https" {
  provider = google
  project  = var.project_id

  name                  = "cptfruls-${var.backend_id}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.lb_target_proxy_https.self_link
}