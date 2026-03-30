##################################################
## Variables
##################################################

variable "project_id" {
  type = string
}
variable "project_folder_code" {
  type = string
}
variable "env" {
  type = string
}
variable "env_main_region" {
  type = string
}
variable "project_id_devstage" {
  type = string
}
variable "project_id_prod" {
  type = string
}
variable "backend_artifacts_repo" {
  type = string
}
variable "web_app_repo_id" {
  type = string
}
variable "backend_app_repo_id" {
  type = string
}

locals {
  project_id_cross       = var.project_id
  project_folder_code    = var.project_folder_code
  env                    = var.env  #tflint-ignore: terraform_unused_declarations
  env_main_region        = var.env_main_region
  project_id_devstage    = var.project_id_devstage
  project_id_prod        = var.project_id_prod
  backend_artifacts_repo = var.backend_artifacts_repo
  web_app_repo_id        = var.web_app_repo_id
  backend_app_repo_id    = var.backend_app_repo_id
}
