variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }

locals {
  project_id             = var.project_id
  project_folder_code    = var.project_folder_code
  env                    = var.env #tflint-ignore: terraform_unused_declarations
  env_main_region        = var.env_main_region
  github_connection_name = "github-connection"
}

output "backend_artifacts_repo" {
  value = "aregrepo-${local.project_folder_code}-backend-cross"
}

output "web_app_repo_id" {
  value = module.repo_web_app.v2_repo_id
}

output "backend_app_repo_id" {
  value = module.repo_backend_app.v2_repo_id
}
