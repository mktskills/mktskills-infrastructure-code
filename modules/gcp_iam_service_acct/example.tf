# EXAMPLE USAGE
#
# module "iam_service_acct" {
#   source = "./gcp_iam_service_acct"
# 
#   service_account_name        = "example-sa"
#   service_account_display_name = "Example Service Account"
#   service_account_description  = "A service account for demonstration purposes."
#   project_id                  = "your-project-id"
#   role                        = "roles/storage.admin"
#   policies                    = ["storage.buckets.get", "storage.buckets.update"]
# }