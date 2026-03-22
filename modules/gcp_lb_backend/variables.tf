variable "project_id" {
  description = "The ID of the project where the resources will be created."
  type        = string
  default     = null
}

variable "backend_id" {
  description = "A unique identifier for the backend."
  type        = string
}

variable "subdomains" {
  description = "A list of subdomains to be created for the website."
  type        = list(string)
  default     = []
}

variable "dns_managed_zone_name" {
  description = "The name of the Google Cloud DNS managed zone."
  type        = string
}

variable "dns_managed_zone_project_id" {
  description = "The project ID of the project where the  Google Cloud DNS managed zone is deployed."
  type        = string
}

variable "serverless_backends" {
  description = "The list of regional backends for serverless services such as Cloud Functions, Cloud Run or App Engine"
  type = list(object({
    name                  = string
    region                = string
    cloud_function_name   = optional(string)
    cloud_run_name        = optional(string)
    appengine_service     = optional(string)
    appengine_version_id  = optional(string)    
  }))
}

variable "security_policy" {
  description = "The name of the security policy to be used for the load balancer."
  type        = string
  default     = null
}

variable "min_tls_version" {
  description = "The minimum TLS version to support for HTTPS connections."
  type = string
  default = "TLS_1_2"  
}

variable "enable_health_check" {
  description = "Enable health checking for the backend service"
  type        = bool
  default     = false
}

variable "health_check_port" {
  description = "Port number for health checking"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path for health checking"
  type        = string
  default     = "/"
}

variable "health_check_proxy_header" {
  description = "Type of proxy header to append before sending data to the backend"
  type        = string
  default     = "NONE"
}

variable "health_check_response" {
  description = "Expected response data from the health check"
  type        = string
  default     = ""
}

variable "health_check_port_specification" {
  description = "Specification of the port to use for health checking"
  type        = string
  default     = "USE_FIXED_PORT"
}

variable "health_check_interval_sec" {
  description = "How often to perform a health check"
  type        = number
  default     = 5
}

variable "health_check_timeout_sec" {
  description = "How long to wait before declaring a timeout"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Consecutive successes required to mark healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Consecutive failures required to mark unhealthy"
  type        = number
  default     = 2
}