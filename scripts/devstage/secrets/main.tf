variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }
variable "service_account_backend_apiserver_email" { type = string }

locals {
  project_id_devstage                     = var.project_id
  project_folder_code                     = var.project_folder_code
  env                                     = var.env             #tflint-ignore: terraform_unused_declarations
  env_main_region                         = var.env_main_region #tflint-ignore: terraform_unused_declarations
  service_account_backend_apiserver_email = var.service_account_backend_apiserver_email
}
