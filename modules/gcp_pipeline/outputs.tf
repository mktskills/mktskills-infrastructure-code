output "trigger_id" {
  description = "The ID of the Cloud Build trigger."
  value       = google_cloudbuild_trigger.repo_trigger.trigger_id
}

output "trigger_resource_id" {
  description = "The resource ID (path) of the Cloud Build trigger."
  value       = google_cloudbuild_trigger.repo_trigger.id
}

output "trigger_create_time" {
  description = "The creation timestamp of the Cloud Build trigger."
  value       = google_cloudbuild_trigger.repo_trigger.create_time
}
