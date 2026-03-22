variable "project_id" {
  description = "The project ID where the secret will be created"
}

variable "project_folder_code" {
  description = "Code of the GCP project to be used"
  type        = string
}

variable "secret_id" {
  description = "The ID of the secret to create"
}

variable "secret_data" {
  description = "The secret data. This is sensitive and should be treated as such."
  type        = string
  default     = null
}


variable "read_principals" {
  description = "List of principals granted read access to the repo"
  type        = list(string)
  default     = []
}

variable "replication_auto" {
  description = "Whether to use automatic replication. If false, user_managed_replicas must be specified."
  type        = bool
  default     = true
}

variable "user_managed_replicas" {
  description = "List of user-managed replica locations. Only used when replication_auto is false."
  type        = list(string)
  default     = []
}

# variable "write_principals" {
#   description = "List of principals granted write access to the repo"
#   type        = list(string)
#   default     = []
# }


