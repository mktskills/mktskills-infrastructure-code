variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env_main_region" { type = string }
variable "dns_zone_project_id" { type = string }

locals {
  project_id_devstage = var.project_id
  project_folder_code = var.project_folder_code
  env_main_region     = var.env_main_region
  dns_zone_project_id = var.dns_zone_project_id
}
