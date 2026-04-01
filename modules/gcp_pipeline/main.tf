locals {
  # v2 (repository_event_config) triggers require explicit logging; default to CLOUD_LOGGING_ONLY
  effective_logging = var.repo_type == "GITHUB_V2" ? coalesce(var.logging, "CLOUD_LOGGING_ONLY") : var.logging

  custom_substitutions_as_env_vars = var.map_substitutions_to_env_vars ? [for k in keys(var.substitutions) : join("=$", [k, k])] : []
  base_substitutions_as_env_vars = var.map_base_substitutions_to_env_vars ? [
    "BUILDER_PROJECT_ID=$PROJECT_ID",
    "BUILD_ID=$BUILD_ID",
    "BUILDER_PROJECT_NUMBER=$PROJECT_NUMBER",
    "BUILDER_LOCATION=$LOCATION",
    "TRIGGER_NAME=$TRIGGER_NAME",
    "COMMIT_SHA=$COMMIT_SHA",
    "SHORT_SHA=$SHORT_SHA",
    "REPO_NAME=$REPO_NAME",
    "REPO_FULL_NAME=$REPO_FULL_NAME",
    "BRANCH_NAME=$BRANCH_NAME",
    "TAG_NAME=$TAG_NAME",
    "REF_NAME=$REF_NAME",
    "TRIGGER_BUILD_CONFIG_PATH=$TRIGGER_BUILD_CONFIG_PATH",
    "BUILDER_SERVICE_ACCOUNT_EMAIL=$SERVICE_ACCOUNT_EMAIL",
    "BUILDER_SERVICE_ACCOUNT=$SERVICE_ACCOUNT"
  ] : []
}

resource "google_cloudbuild_trigger" "repo_trigger" {
  provider = google
  project  = var.project_id

  location        = var.location
  name            = "cbldtrig-${var.pipeline_id}"
  description     = var.description
  service_account = var.service_account_id != null ? google_service_account_iam_binding.cloudbuild_service_account_user[0].service_account_id : null

  dynamic "trigger_template" {
    for_each = var.repo_type == "SOURCEREPO" ? [1] : []
    content {
      branch_name = var.repo_branch_regexp
      repo_name   = var.repo_name
    }
  }

  dynamic "github" {
    for_each = var.repo_type == "GITHUB" ? [1] : []
    content {
      name  = split("/", var.repo_name)[1]
      owner = split("/", var.repo_name)[0]

      dynamic "push" {
        for_each = var.repo_trigger == "PUSH" ? [1] : []
        content {
          branch = var.repo_branch_regexp
        }
      }

      dynamic "pull_request" {
        for_each = var.repo_trigger == "PULL_REQUEST" ? [1] : []
        content {
          branch = var.repo_branch_regexp
        }
      }
    }
  }

  dynamic "repository_event_config" {
    for_each = var.repo_type == "GITHUB_V2" ? [1] : []
    content {
      repository = var.v2_repo_id

      dynamic "push" {
        for_each = var.repo_trigger == "PUSH" ? [1] : []
        content {
          branch = var.repo_branch_regexp
        }
      }

      dynamic "pull_request" {
        for_each = var.repo_trigger == "PULL_REQUEST" ? [1] : []
        content {
          branch = var.repo_branch_regexp
        }
      }
    }
  }

  build {
    substitutions = var.substitutions
    timeout       = var.timeout

    dynamic "step" {
      for_each = var.steps
      content {
        name       = step.value.name
        args       = lookup(step.value, "args", null)
        entrypoint = lookup(step.value, "entrypoint", null)
        script     = lookup(step.value, "script", null)
      }
    }

    options {
      substitution_option = "ALLOW_LOOSE"
      env = concat(
        var.env_vars,
        local.base_substitutions_as_env_vars,
        local.custom_substitutions_as_env_vars
      )
      logging      = local.effective_logging
      machine_type = var.machine_type
    }
  }

  ignored_files  = var.ignored_files
  included_files = var.included_files
}

data "google_project" "project" {
  provider   = google
  project_id = var.project_id
}

resource "google_service_account" "pipeline_service_account" {
  provider = google
  project  = var.project_id
  count    = var.service_account_id != null ? 1 : 0

  account_id   = var.service_account_id
  display_name = "Cloud Build Service Account for ${var.pipeline_id}"
  description  = "A service account for the Cloud Build pipeline ${var.pipeline_id} to run in Cloud Build."
}

resource "google_service_account_iam_binding" "cloudbuild_service_account_user" {
  provider = google
  count    = var.service_account_id != null ? 1 : 0

  service_account_id = google_service_account.pipeline_service_account[0].name
  role               = "roles/iam.serviceAccountUser"

  members = [
    # 1st gen Cloud Build P4SA
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    # 2nd gen Cloud Build service agent (repository_event_config triggers)
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_member" "access_build" {
  provider = google
  for_each = { for build_policy in var.build_policies : build_policy.role => build_policy }
  project  = var.project_id

  role = each.value.role
  member = (var.service_account_id != null
    ? "serviceAccount:${google_service_account.pipeline_service_account[0].email}"
    : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  )

  dynamic "condition" {
    for_each = try(each.value.expression, null) != null ? [each.value] : []
    content {
      title       = try(each.value.title, null) != null ? each.value.title : "Build policy for ${var.pipeline_id}"
      description = try(each.value.description, null) != null ? each.value.description : "Build policy"
      expression  = each.value.expression
    }
  }
}

resource "google_project_iam_member" "cross_project_access_deploy" {
  provider = google
  for_each = { for deploy_policy in var.deploy_policies : deploy_policy.role => deploy_policy }
  project  = var.deploy_project_id

  role = each.value.role
  member = (var.service_account_id != null
    ? "serviceAccount:${google_service_account.pipeline_service_account[0].email}"
    : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  )

  dynamic "condition" {
    for_each = try(each.value.expression, null) != null ? [each.value] : []
    content {
      title       = try(each.value.title, null) != null ? each.value.title : "Cross project access for ${var.pipeline_id}"
      description = try(each.value.description, null) != null ? each.value.description : "Cross project access policy"
      expression  = each.value.expression
    }
  }
}

resource "google_service_account_iam_member" "cross_project_sa_access_deploy" {
  provider = google
  for_each = toset(var.deploy_act_as_service_account)

  service_account_id = "projects/${var.deploy_project_id}/serviceAccounts/${each.value}"
  role               = "roles/iam.serviceAccountUser"

  member = (var.service_account_id != null
    ? "serviceAccount:${google_service_account.pipeline_service_account[0].email}"
    : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  )
}

resource "google_artifact_registry_repository_iam_member" "private_library_artifact_registry_access" {
  provider = google
  for_each = toset(var.read_artifacts_repos)

  project    = split("/", each.value)[0]
  location   = split("/", each.value)[1]
  repository = split("/", each.value)[2]
  role       = "roles/artifactregistry.reader"
  member = (var.service_account_id != null
    ? "serviceAccount:${google_service_account.pipeline_service_account[0].email}"
    : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  )
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_write_access" {
  provider = google
  for_each = toset(var.write_artifacts_repos)

  project    = split("/", each.value)[0]
  location   = split("/", each.value)[1]
  repository = split("/", each.value)[2]
  role       = "roles/artifactregistry.writer"
  member = (var.service_account_id != null
    ? "serviceAccount:${google_service_account.pipeline_service_account[0].email}"
    : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  )
}
