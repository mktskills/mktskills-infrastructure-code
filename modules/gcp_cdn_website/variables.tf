variable "project_id" {
  description = "The ID of the project where the resources will be created."
  type        = string
  default     = null
}

variable "website_id" {
  description = "A unique identifier for the website."
  type        = string
}

variable "bucket_location" {
  description = "The location of the Google Cloud Storage bucket."
  type        = string
  default     = "us-central1"
}

variable "subdomains" {
  description = "A list of subdomains to be created for the website."
  type        = list(string)
  default     = []
}

variable "full_domains" {
  description = "A list of full domain names to be created for the website."
  type        = list(string)
  default     = null
}

variable "dns_managed_zone_name" {
  description = "The name of the Google Cloud DNS managed zone. If not provided, DNS records will not be created."
  type        = string
  default     = null
}

variable "dns_managed_zone_project_id" {
  description = "The project ID of the project where the Google Cloud DNS managed zone is deployed. Required if dns_managed_zone_name is provided."
  type        = string
  default     = null
}

variable "cdn_proxy_header" {
  description = "The HTTP header name used to pass the client's original IP address."
  type        = string
  default     = "X-Forwarded-For"
}

variable "main_page" {
  description = "Path to main page loaded when browsing root path"
  type        = string
  default     = "index.html"
}

variable "not_found_page" {
  description = "Path to 404 page loaded when browsing a non existant path"
  type        = string
  default     = "404.html"
}

variable "cdn_policy" {
  description = "Cloud CDN configuration for this Backend Bucket."
  type        = object({
    cache_mode                         = optional(string)
    serve_while_stale                  = optional(number)
    request_coalescing                 = optional(any)
    bypass_cache_on_request_headers    = optional(list(object({
          header_name = string
        })))
    cache_key_policy                   = optional(list(object({
          query_string_whitelist = optional(list(string))
          include_http_headers   = optional(list(string))
        })))
    signed_url_cache_max_age_sec       = optional(number)
    negative_caching                   = optional(bool)
    negative_caching_policy            = optional(list(object({
          code = optional(number)
          ttl  = optional(number)
        })))
    max_ttl                            = optional(number)
    default_ttl                        = optional(number)
    client_ttl                         = optional(number)
  })
  default     = null
}

variable "compression_mode" {
  description = "Compress text responses using Brotli or gzip compression, based on the client's Accept-Encoding header. Possible values are AUTOMATIC and DISABLED."
  type = string
  default = null
}

variable "edge_security_policy" {
  description = "The security policy associated with this backend bucket."
  type = string
  default = null
}

variable "custom_request_headers" {
  description = "A list of custom request headers to be added to the CDN configuration. Only used when backend_type is 'EXTERNAL_URL'."
  type = list(string)
  default = []
}

variable "custom_response_headers" {
  description = "A list of custom response headers to be added to the CDN configuration."
  type = list(string)
  default = []
}

variable "min_tls_version" {
  description = "The minimum TLS version to support for HTTPS connections."
  type = string
  default = "TLS_1_2"  
}

variable "custom_ssl_certificate" {
  description = "The self link of the custom SSL certificate to use"
  type        = string
  default     = null
}

variable "backend_type" {
  description = "The type of backend for the CDN. Can be 'BUCKET', 'EXTERNAL_URL' or 'REDIRECT'."
  type        = string
  default     = "BUCKET"
  validation {
    condition     = contains(["BUCKET", "EXTERNAL_URL", "REDIRECT"], var.backend_type)
    error_message = "Allowed values for backend_type are 'BUCKET', 'EXTERNAL_URL' or 'REDIRECT'."
  }
}

variable "external_url" {
  description = "The external URL to use as the backend when backend_type is 'external_url' or 'redirect'."
  type        = string
  default     = null
}

variable "bucket_editors" {
  description = "List of IAM members granted roles/storage.objectAdmin on the website bucket (e.g. 'group:team@example.com'). Only used when backend_type is 'BUCKET'."
  type        = list(string)
  default     = []
}

variable "enable_llm_discovery" {
  description = "When true, adds a URL map route rule that redirects GET requests with Accept: text/markdown to /llms.txt. Also requires the caller to include Accept in cdn_policy.cache_key_policy.include_http_headers."
  type        = bool
  default     = false
}

variable "spa_fallback_path" {
  description = "When set, adds a custom error response policy to the HTTPS URL map that intercepts 4xx responses from the backend and serves this path with HTTP 200. Use for SPAs where virtual routes (e.g. /app/clients) must return index.html rather than a 404. Example: \"/app/index.html\"."
  type        = string
  default     = null
}

