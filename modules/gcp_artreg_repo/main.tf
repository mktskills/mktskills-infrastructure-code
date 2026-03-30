resource "google_project_service" "artifact_registry" {
  provider = google
  project  = var.project_id

  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "artreg_repo" {
  provider = google
  project  = var.project_id

  repository_id = var.repository_id
  format        = var.format
  location      = var.location
  description   = var.description
  labels        = var.labels
  kms_key_name  = var.kms_key_name
  mode          = var.mode

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.docker_immutable_tags ? [1] : []
    content {
      immutable_tags = var.docker_immutable_tags
    }
  }

  dynamic "maven_config" {
    for_each = var.format == "MAVEN" ? [1] : []
    content {
      allow_snapshot_overwrites = var.maven_allow_snapshot_overwrites
      version_policy            = var.maven_version_policy
    }
  }

  dynamic "virtual_repository_config" {
    for_each = var.mode == "VIRTUAL_REPOSITORY" ? [1] : []
    content {
      dynamic "upstream_policies" {
        for_each = { for upstream_policy in var.virtual_repo_upstream_policies : upstream_policy.id => upstream_policy }
        content {
          id         = upstream_policies.value.id
          repository = upstream_policies.value.repository
          priority   = lookup(upstream_policies.value, "priority", null)
        }
      }
    }
  }

  dynamic "remote_repository_config" {
    for_each = var.mode == "REMOTE_REPOSITORY" ? [1] : []
    content {
      description = var.remote_repo_description

      dynamic "docker_repository" {
        for_each = var.format == "DOCKER" ? [1] : []
        content {
          public_repository = var.remote_repo_address
        }
      }

      dynamic "maven_repository" {
        for_each = var.format == "MAVEN" ? [1] : []
        content {
          public_repository = var.remote_repo_address
        }
      }

      dynamic "npm_repository" {
        for_each = var.format == "NPM" ? [1] : []
        content {
          public_repository = var.remote_repo_address
        }
      }

      dynamic "python_repository" {
        for_each = var.format == "PYTHON" ? [1] : []
        content {
          public_repository = var.remote_repo_address
        }
      }
    }
  }

  depends_on = [google_project_service.artifact_registry]
}

resource "google_artifact_registry_repository_iam_member" "artreg_repo_readers" {
  provider = google
  project  = var.project_id
  count    = length(var.read_principals)

  location   = var.location
  repository = google_artifact_registry_repository.artreg_repo.name

  role   = "roles/artifactregistry.reader"
  member = var.read_principals[count.index]
}

resource "google_artifact_registry_repository_iam_member" "artreg_repo_writers" {
  provider = google
  project  = var.project_id
  count    = length(var.write_principals)

  location   = var.location
  repository = google_artifact_registry_repository.artreg_repo.name

  role   = "roles/artifactregistry.writer"
  member = var.write_principals[count.index]
}