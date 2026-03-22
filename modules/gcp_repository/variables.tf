variable "repository_id" {
  description = "A unique identifier for the repository."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The ID of the Google Cloud project where the repository will be created."
  type        = string
}

variable "location" {
  description = "GCP region for the Cloud Build v2 repository connection."
  type        = string
  default     = null
}

variable "repo_name" {
  description = "Name for the Cloud Build v2 repository resource."
  type        = string
  default     = null
}

variable "github_owner" {
  description = "GitHub organisation or user that owns the repository."
  type        = string
  default     = null
}

variable "github_repo" {
  description = "GitHub repository name (without owner prefix)."
  type        = string
  default     = null
}

variable "github_connection_name" {
  description = "Name of the existing Cloud Build v2 GitHub connection. Must be authorised manually in the GCP Console before terraform apply."
  type        = string
  default     = "github-mktskills"
}

variable "publish_changes" {
  description = "Whether changes to the repository should be published to a Pub/Sub topic."
  type        = bool
  default     = false
}

variable "publishing_service_account" {
  description = "The email address of the service account that will publish changes to the repository."
  type        = string
  default     = null
}
