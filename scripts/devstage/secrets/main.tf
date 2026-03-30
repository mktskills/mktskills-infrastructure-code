variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "service_account_backend_apiserver_email" { type = string }

locals {
  project_id_devstage                     = var.project_id
  project_folder_code                     = var.project_folder_code
  service_account_backend_apiserver_email = var.service_account_backend_apiserver_email
}
