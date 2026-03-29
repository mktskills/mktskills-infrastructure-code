variable "managed_zone_name" {
  type        = string
  description = "The managed zone name suffix. The resource name will be 'dnszone-{managed_zone_name}'. If not provided, derived from dns_name by replacing dots with underscores."
  default     = null
}

variable "dns_name" {
  type        = string
  description = "The DNS name of the managed zone (e.g. 'mktskills.ai.')."
}

variable "managed_zone_description" {
  type        = string
  description = "Description of the managed zone. Defaults to 'DNS Zone for {dns_name}'."
  default     = null
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where the managed zone will be created."
}

variable "dnssec_config" {
  type = object({
    kind          = string
    non_existence = string
    state         = string
    default_key_specs = list(object({
      algorithm  = string
      key_length = number
      key_type   = string
      kind       = string
    }))
  })
  description = "DNSSEC configuration. Null disables DNSSEC."
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the managed zone."
  default     = {}
}

variable "visibility" {
  type        = string
  description = "Zone visibility: 'public' or 'private'."
  default     = "public"
}

variable "private_visibility_config" {
  type = object({
    networks     = list(string)
    gke_clusters = list(string)
  })
  description = "Private visibility configuration (required when visibility = 'private')."
  default     = null
}

variable "forwarding_config" {
  type = object({
    target_name_servers = list(object({
      ipv4_address    = string
      forwarding_path = string
    }))
  })
  description = "Forwarding configuration for the managed zone."
  default     = null
}

variable "cloud_logging_enabled" {
  type        = bool
  description = "Whether to enable Cloud Logging for DNS queries."
  default     = null
}

variable "dns_records" {
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    rrdatas = list(string)
  }))
  description = "Static DNS records to create in the zone. CDN and LB A records are managed by their respective modules."
  default     = []
}
