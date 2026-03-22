variable "project_id" {
  description = "The ID of the project where the bucket will be created"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket. It must be globally unique."
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
  default     = "us-central1"
}

variable "storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket when deleting"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Whether to enable versioning for the bucket"
  type        = bool
  default     = null
}

variable "lifecycle_rules" {
  description = "The list lifecycle rules for the bucket"
  type        = list(object({
    action_type                        = string
    action_storage_class               = optional(string)
    condition_age                      = optional(number)
    condition_created_before           = optional(string)
    condition_with_state               = optional(string)
    condition_matches_storage_class    = optional(list(string), [])
    condition_matches_prefix           = optional(list(string), [])
    condition_matches_suffix           = optional(list(string), [])
    condition_num_newer_versions       = optional(number)
    condition_custom_time_before       = optional(string)
    condition_days_since_custom_time   = optional(number)
    condition_days_since_noncurrent_time = optional(number)
    condition_noncurrent_time_before   = optional(string)
  }))
  default     = []
}

variable "default_kms_key_name" {
  description = "The name of the default KMS key to encrypt the bucket"
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "The CORS configuration rules for the bucket"
  type        = list(object({
    origin = list(string)
    method = list(string)
    response_header = list(string)
    max_age_seconds = number
  }))
  default     = []
}

variable "retention_policy" {
  description = "The retention policy configuration of the bucket"
  type        = object({
    retention_period  = number
    is_locked         = bool
  })
  default     = null
}

variable "logging" {
  description = "The logging configuration of the bucket"
  type        = object({
    log_bucket         = string
    log_object_prefix  = string
  })
  default     = null
}

variable "website" {
  description = "The website configuration of the bucket"
  type        = object({
    main_page_suffix = string
    not_found_page   = string
  })
  default     = null
}

variable "public_read_access" {
  description = "Indicate weather read access shall be open to all users."
  type        = bool
  default     = false
}

variable "bucket_listers" {
  description = "List of IAM principals to be granted list access to the bucket and its content."
  type        = list(string)
  default     = []
}

variable "bucket_readers" {
  description = "List of IAM principals to be granted read access to the bucket content."
  type        = list(string)
  default     = []
}

variable "bucket_writers" {
  description = "List of IAM principals to be granted write (also read/create/delete) access to the bucket content."
  type        = list(string)
  default     = []
}
