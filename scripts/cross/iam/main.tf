variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }

locals {
  project_id          = var.project_id           #tflint-ignore: terraform_unused_declarations
  project_folder_code = var.project_folder_code  #tflint-ignore: terraform_unused_declarations
  env                 = var.env                  #tflint-ignore: terraform_unused_declarations
  env_main_region     = var.env_main_region      #tflint-ignore: terraform_unused_declarations
}
