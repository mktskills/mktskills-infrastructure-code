resource "google_sourcerepo_repository" "repository" {
  provider = google
  project  = var.project_id

  name    = "srepo-${var.repository_id}"

  dynamic "pubsub_configs" {
    for_each = var.publish_changes ? [1] : []
    content {
      topic = google_pubsub_topic.topic.id
      message_format = "JSON"
      service_account_email = var.publishing_service_account
    }
  }
}

resource "google_pubsub_topic" "topic" {
  provider = google
  count = var.publish_changes ? 1 : 0

  name     = "pbsbtopc-${var.repository_id}"
}

