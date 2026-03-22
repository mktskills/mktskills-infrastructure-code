output "repository_name" {
  description = "The name of the newly created Google Cloud Repository."
  value       = var.repository_id != null ? google_sourcerepo_repository.repository[0].name : null
}
output "repository_url" {
  description = "The URL of the newly created Google Cloud Repository."
  value       = var.repository_id != null ? google_sourcerepo_repository.repository[0].url : null
}

output "repository_id" {
  description = "The id of the newly created Google Cloud Repository."
  value       = var.repository_id != null ? google_sourcerepo_repository.repository[0].id : null
}

output "repository_size" {
  description = "The size of the newly created Google Cloud Repository."
  value       = var.repository_id != null ? google_sourcerepo_repository.repository[0].size : null
}

output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic created for this repository, if applicable."
  value       = var.publish_changes ? google_pubsub_topic.topic[0].name : null
}

output "pubsub_topic_id" {
  description = "The id of the Pub/Sub topic created for this repository, if applicable."
  value       = var.publish_changes ? google_pubsub_topic.topic[0].id : null
}
