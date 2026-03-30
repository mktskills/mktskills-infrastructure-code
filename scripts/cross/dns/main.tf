variable "project_id" { type = string }
variable "project_folder_code" { type = string }

locals {
  project_id          = var.project_id
  project_folder_code = var.project_folder_code
}

output "zone_name" {
  value       = module.dns_zone_mktskillsai.zone_name
  description = "DNS zone resource name (dnszone-mktskills-mktskillsai). Referenced by CDN and LB modules in the prod stack."
}

output "name_servers" {
  value       = module.dns_zone_mktskillsai.name_servers
  description = "Delegate mktskills.ai to these name servers at your registrar after first apply."
}
