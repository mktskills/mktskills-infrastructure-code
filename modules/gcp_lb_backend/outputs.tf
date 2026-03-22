output "lb_ip_address" {
  description = "The IP address of the Google Compute Engine instance used for the CDN."
  value       = google_compute_global_address.lb_ip.address
}

output "lb_certificate_self_link" {
  description = "The self-link of the Google Compute Engine SSL certificate used for the CDN."
  value       = google_compute_managed_ssl_certificate.lb_certificate.self_link
}

output "lb_dns_records" {
  description = "A list of DNS records created for the website subdomains."
  value       = [for v in google_dns_record_set.lb_dns_records : v.rrdatas[0]]
}
