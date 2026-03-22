variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }

locals {
  project_id          = var.project_id
  project_folder_code = var.project_folder_code
  env                 = var.env
  env_main_region     = var.env_main_region
}

output "backend_artifacts_repo" {
  value = "aregrepo-${local.project_folder_code}-backend-cross"
}
