variable "project_id" {
  description = "The ID of the project where the service account will be created."
  type        = string
}

variable "service_account_name" {
  description = "The unique name for the service account."
  type        = string
}

variable "service_account_display_name" {
  description = "The display name for the service account."
  type        = string
}

variable "service_account_description" {
  description = "The description for the service account."
  type        = string
}

variable "roles" {
  description = "The roles to be assigned to the service account."
  type        = list(string)
  default     = []
}

variable "foreign_project_roles" {
  description = "The roles to be assigned to the service account in a foreign project."
  type        = list(object({
    project_id = string
    roles      = list(string)
  }))
  default     = []
}

variable "policies" {
  description = "A list of IAM policies to be assigned to the custom role for the service account. Leave it empty if no custom role is needed."
  type        = list(string)
  default     = []
}

variable "members" {
  description = "A list of members to be assigned to the service account."
  type        = list(string)
  default     = []
}

variable "members_token_creator" {
  description = "A list of members to be assigned to the service account with additional token creator role."
  type        = list(string)
  default     = []
}
