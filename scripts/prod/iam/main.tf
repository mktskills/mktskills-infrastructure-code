variable "project_id" { type = string }
variable "project_folder_code" { type = string }

locals {
  project_id          = var.project_id
  project_folder_code = var.project_folder_code
}

output "service_account_backend_apiserver_email" {
  value = module.sa_backend_apiserver.service_account_email
}
