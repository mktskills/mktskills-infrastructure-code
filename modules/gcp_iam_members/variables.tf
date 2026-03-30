variable "project_id" {
  description = "The ID of the project where the service account will be created."
  type        = string
}

variable "users" {
  description = "A list of user email addresses"
  default     = []
  type        = list(string)
}

variable "groups" {
  description = "A list of group email addresses"
  default     = []
  type        = list(string)
}

variable "serviceAccounts" {
  description = "A list of service account email addresses"
  default     = []
  type        = list(string)
}

variable "domains" {
  description = "A list of domain names"
  default     = []
  type        = list(string)
}

variable "roles_with_conditions" {
  description = "A list of IAM roles with their corresponding condition expressions"
  default     = []
  type = list(object({
    role                 = string
    condition_title      = optional(string)
    condition_expression = optional(string)
  }))
}