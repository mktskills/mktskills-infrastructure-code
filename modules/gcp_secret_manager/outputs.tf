output "secret_id" {
  description = "The ID of the created secret."
  value       = google_secret_manager_secret.my_secret.id
}

output "secret_name" {
  description = "The resource name of the created secret."
  value       = google_secret_manager_secret.my_secret.name
}
