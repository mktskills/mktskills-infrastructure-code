resource "google_secret_manager_secret" "my_secret" {
  project   = var.project_id
  secret_id = var.secret_id

  dynamic "replication" {
    for_each = var.replication_auto ? [1] : []
    content {
      auto {}
    }
  }

  dynamic "replication" {
    for_each = var.replication_auto ? [] : [1]
    content {
      user_managed {
        dynamic "replicas" {
          for_each = var.user_managed_replicas
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_iam_member" "member" {
  count   = length(var.read_principals)
  project = var.project_id

  secret_id = google_secret_manager_secret.my_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = var.read_principals[count.index]

  depends_on = [google_secret_manager_secret.my_secret]
}

resource "google_secret_manager_secret_version" "my_secret_version" {
  count = var.secret_data != null ? 1 : 0

  secret      = google_secret_manager_secret.my_secret.id
  secret_data = var.secret_data

  depends_on = [google_secret_manager_secret.my_secret]
}
