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
variable "project_id_prod" {
  type = string
}
variable "backend_artifacts_repo" {
  type = string
}

locals {
  project_id              = var.project_id
  project_folder_code     = var.project_folder_code
  env                     = var.env
  env_main_region         = var.env_main_region
  project_id_prod         = var.project_id_prod
  backend_artifacts_repo  = var.backend_artifacts_repo
}
