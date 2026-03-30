variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }

locals {
  project_id_devstage = var.project_id
  project_folder_code = var.project_folder_code
  env                 = var.env
  env_main_region     = var.env_main_region
}

output "service_account_backend_apiserver_email" {
  value = module.sa_backend_apiserver_dev.service_account_email
}
