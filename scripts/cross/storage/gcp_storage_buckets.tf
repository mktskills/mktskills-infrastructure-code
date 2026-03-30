##################################################
## Storage Buckets — Cross
##################################################

# Artifacts bucket: stores zipped web build artifacts for prod promotion
module "bucket_webapp_artifacts" {
  source = "../../../modules/gcp_storage_bucket"
  providers = {
    google = google
  }
  project_id  = local.project_id
  bucket_name = "${local.project_folder_code}-webapp-artifacts-cross"
  location    = local.env_main_region
  lifecycle_rules = [{
    action_type   = "Delete"
    condition_age = 30
  }]
}

# TF state bucket (created manually before first terraform init)
# module "bucket_tfstate" { ... }
