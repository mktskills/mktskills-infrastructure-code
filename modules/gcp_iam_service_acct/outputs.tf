output "service_account_email" {
  description = "The email address of the created service account."
  value       = google_service_account.service_account.email
}

output "service_account_id" {
  description = "The unique ID of the created service account."
  value       = google_service_account.service_account.unique_id
}

output "custom_role_id" {
  description = "The ID of the created custom role if any policies were provided. Empty if no custom role was created."
  value       = length(var.policies) > 0 ? google_project_iam_custom_role.custom_role[0].id : ""
}
