output "repository_name" {
  value       = google_artifact_registry_repository.artreg_repo.name
  description = "The name of the Artifact Registry repository."
}

output "repository_id" {
  value       = google_artifact_registry_repository.artreg_repo.repository_id
  description = "The ID of the Artifact Registry repository."
}

output "repository_create_time" {
  value       = google_artifact_registry_repository.artreg_repo.create_time
  description = "The time when the Artifact Registry repository was created."
}

output "repository_update_time" {
  value       = google_artifact_registry_repository.artreg_repo.update_time
  description = "The time when the Artifact Registry repository was last updated."
}