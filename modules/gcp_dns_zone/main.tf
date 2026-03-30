#tfsec:ignore:google-dns-enable-dnssec
resource "google_dns_managed_zone" "managed_zone" {
  provider = google
  project  = var.project_id

  name        = var.managed_zone_name != null ? "dnszone-${var.managed_zone_name}" : replace(var.dns_name, ".", "_")
  dns_name    = var.dns_name
  description = var.managed_zone_description != null ? var.managed_zone_description : "DNS Zone for ${var.dns_name}"

  dynamic "dnssec_config" {
    for_each = var.dnssec_config != null ? [1] : []
    content {
      kind          = lookup(var.dnssec_config, "kind", null)
      non_existence = lookup(var.dnssec_config, "non_existence", null)
      state         = lookup(var.dnssec_config, "state", null)

      dynamic "default_key_specs" {
        for_each = lookup(var.dnssec_config, "default_key_specs", [])
        content {
          kind       = lookup(default_key_specs.value, "kind", null)
          algorithm  = lookup(default_key_specs.value, "algorithm", null)
          key_length = lookup(default_key_specs.value, "key_length", null)
          key_type   = lookup(default_key_specs.value, "key_type", null)
        }
      }
    }
  }

  labels = var.labels

  visibility = var.visibility

  dynamic "private_visibility_config" {
    for_each = var.private_visibility_config != null ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.private_visibility_config.networks
        content {
          network_url = networks.value
        }
      }

      dynamic "gke_clusters" {
        for_each = lookup(var.private_visibility_config, "gke_clusters", [])
        content {
          gke_cluster_name = gke_clusters.value
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = var.forwarding_config != null ? [1] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.forwarding_config.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = lookup(target_name_servers.value, "forwarding_path", [])
        }
      }
    }
  }

  dynamic "cloud_logging_config" {
    for_each = var.cloud_logging_enabled != null ? [1] : []
    content {
      enable_logging = var.cloud_logging_enabled
    }
  }
}

resource "google_dns_record_set" "dns_records" {
  provider = google
  for_each = { for record in var.dns_records : "${record.type}_${record.name}_${var.dns_name}" => record }
  project  = var.project_id

  name         = each.value.name != "" ? "${each.value.name}.${var.dns_name}" : var.dns_name
  managed_zone = google_dns_managed_zone.managed_zone.name
  type         = each.value.type
  ttl          = lookup(each.value, "ttl", 300)
  rrdatas      = each.value.type == "TXT" ? [for rrdata in lookup(each.value, "rrdatas", []) : replace("\"${rrdata}\"", " ", "\" \"")] : lookup(each.value, "rrdatas", [])
}
