locals {
  flattened_foreign_project_roles = flatten([
    for item in var.foreign_project_roles : [
      for role in item.roles : {
        project_id = item.project_id
        role       = role
      }
    ]
  ])
  foreign_project_roles_set = {
    for obj in local.flattened_foreign_project_roles :
    "${obj.project_id}--${obj.role}" => obj
  }
}

resource "google_service_account" "service_account" {
  provider = google
  project  = var.project_id

  account_id   = var.service_account_name
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

resource "google_project_iam_member" "role_member" {
  provider = google
  for_each = toset(var.roles)
  project  = var.project_id

  role = each.value

  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "foreign_role_member" {
  provider = google
  for_each = local.foreign_project_roles_set
  project  = each.value.project_id

  role = each.value.role

  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_custom_role" "custom_role" {
  provider = google
  count    = length(var.policies) > 0 ? 1 : 0
  project  = var.project_id

  role_id = "iamcrole-${var.service_account_name}"
  title   = "Custom Role for ${var.service_account_display_name}"

  permissions = var.policies
}

resource "google_project_iam_member" "custom_role_member" {
  provider = google
  count    = length(var.policies) > 0 ? 1 : 0
  project  = var.project_id

  role = "projects/${var.project_id}/roles/${google_project_iam_custom_role.custom_role[0].role_id}"

  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account_iam_member" "service_account_user" {
  provider = google
  count    = length(var.members)

  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.serviceAccountUser"

  member = var.members[count.index]
}

resource "google_service_account_iam_member" "service_account_token_creator" {
  provider = google
  count    = length(var.members_token_creator)

  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"

  member = var.members_token_creator[count.index]
}
