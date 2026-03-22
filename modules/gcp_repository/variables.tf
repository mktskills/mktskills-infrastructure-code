variable "repository_id" {
  description = "A unique identifier for the repository."
  type        = string
}

variable "project_id" {
  description = "The ID of the Google Cloud project where the repository will be created."
  type        = string
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
