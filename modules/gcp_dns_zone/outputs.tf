output "zone_id" {
  value       = google_dns_managed_zone.managed_zone.id
  description = "Full resource ID: projects/{{project}}/managedZones/{{name}}"
}

output "zone_name" {
  value       = google_dns_managed_zone.managed_zone.name
  description = "The zone resource name (e.g. 'dnszone-mktskills-mktskillsai'). Use this as dns_managed_zone_name in CDN and LB modules to ensure correct dependency ordering."
}

output "name_servers" {
  value       = google_dns_managed_zone.managed_zone.name_servers
  description = "Delegate your domain to these name servers at your registrar."
}
