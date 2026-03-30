variable "project_id" { type = string }
variable "project_folder_code" { type = string }
variable "env" { type = string }
variable "env_main_region" { type = string }

locals {
  project_id          = var.project_id
  project_folder_code = var.project_folder_code
  env                 = var.env           #tflint-ignore: terraform_unused_declarations
  env_main_region     = var.env_main_region  #tflint-ignore: terraform_unused_declarations
}

output "zone_name" {
  value       = module.dns_zone_mktskillsai.zone_name
  description = "DNS zone resource name (dnszone-mktskills-mktskillsai). Referenced by CDN and LB modules in the prod stack."
}

output "name_servers" {
  value       = module.dns_zone_mktskillsai.name_servers
  description = "Delegate mktskills.ai to these name servers at your registrar after first apply."
}
