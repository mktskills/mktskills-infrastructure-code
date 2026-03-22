output "cdn_ip_address" {
  description = "The IP address of the Google Compute Engine instance used for the CDN."
  value       = google_compute_global_address.cdn_ip.address
}

output "cdn_certificate_self_link" {
  description = "The self-link of the managed SSL certificate"
  value       = length(google_compute_managed_ssl_certificate.cdn_certificate) > 0 ? google_compute_managed_ssl_certificate.cdn_certificate[0].self_link : null
}

output "cdn_dns_records" {
  description = "A list of DNS records created for the website subdomains."
  value       = [for v in google_dns_record_set.cdn_dns_records : v.rrdatas[0]]
}
