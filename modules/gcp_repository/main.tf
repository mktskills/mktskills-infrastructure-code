# Cloud Build v2 GitHub repository connection
# Requires: GitHub connection manually authorised in GCP Console first
# (Cloud Build > Repositories > Connect Repository → choose the connection named var.github_connection_name)
resource "google_cloudbuildv2_repository" "github_repo" {
  count    = var.github_owner != null && var.github_repo != null ? 1 : 0
  provider = google
  project  = var.project_id
  location = var.location
  name     = var.repo_name

  parent_connection = "projects/${var.project_id}/locations/${var.location}/connections/${var.github_connection_name}"
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}

# Legacy Cloud Source Repositories (only created when repository_id is set)
resource "google_sourcerepo_repository" "repository" {
  count    = var.repository_id != null ? 1 : 0
  provider = google
  project  = var.project_id

  name = "srepo-${var.repository_id}"

  dynamic "pubsub_configs" {
    for_each = var.publish_changes ? [1] : []
    content {
      topic                 = google_pubsub_topic.topic[0].id
      message_format        = "JSON"
      service_account_email = var.publishing_service_account
    }
  }
}

resource "google_pubsub_topic" "topic" {
  provider = google
  count    = var.publish_changes && var.repository_id != null ? 1 : 0

  name = "pbsbtopc-${var.repository_id}"
}

