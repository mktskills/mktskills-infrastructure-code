# Cloud Storage Bucket Module

## Module Code
*gcp_storage_bucket*

## Description

This Terraform module creates a Google Cloud Storage (GCS) bucket with various configurations, providing a versatile cloud storage solution. Features include versioning, lifecycle rules, encryption, CORS, retention policy, logging, and website settings. Additionally, it supports granting public read access to the created bucket.

The module supports customizing the bucket with detailed configuration options, allowing users to enforce data retention policies, manage object lifecycles, and configure Cross-Origin Resource Sharing (CORS) rules. The module also enables the creation of a static website using GCS, with custom main page and error page settings.

Security is addressed through the module's support for encryption, specifically allowing the use of a default KMS key. To further enhance access control, the module can be set to grant public read access or use IAM policies to manage user permissions. These features make this GCS bucket module flexible and adaptable to various storage requirements.

## Usage Cases

Create a simple GCS bucket with public read access.

```
module "storage_bucket" {
  source          = "./modules/gcp_storage_bucket"
  project_id      = "your-project-id"

  bucket_name     = "my-bucket"
  location        = "US"
  public_read_access = true
}
```

Create a GCS bucket with versioning, retention policy, and default KMS encryption.

```
module "storage_bucket" {
  source          = "./modules/gcp_storage_bucket"
  project_id      = "your-project-id"

  bucket_name     = "my-encrypted-bucket"
  location        = "US"
  versioning      = true
  default_kms_key_name = "projects/my-project/locations/us/keyRings/my-key-ring/cryptoKeys/my-key"
  retention_policy = {
    retention_period = 60
    is_locked        = true
  }
}
```

Create a GCS bucket with lifecycle rules and CORS configuration.

```
module "storage_bucket" {
  source          = "./modules/gcp_storage_bucket"
  project_id      = "your-project-id"

  bucket_name     = "my-lifecycle-bucket"
  location        = "US"
  lifecycle_rules = [
    {
      action_type = "Delete"
      condition = {
        age = 30
      }
    }
  ]
  cors_rules = [
    {
      origin          = ["https://example.com"]
      method          = ["GET", "POST"]
      response_header = ["Content-Type"]
      max_age_seconds = 3600
    }
  ]
}
```

A complete example.

```
module "storage_bucket" {
  source          = "./modules/gcp_storage_bucket"
  project_id      = "your-project-id"

  bucket_name             = "example-bucket"
  location                = "us-central1"
  storage_class           = "STANDARD"
  force_destroy           = false
  versioning              = true
  default_kms_key_name    = "projects/your-project-id/locations/global/keyRings/your-keyring/cryptoKeys/your-key"
  public_read_access      = true

  lifecycle_rule = {
    action_type                = "Delete"
    action_storage_class       = null
    condition_age              = 30
    condition_created_before   = null
    condition_with_state       = "ANY"
    condition_matches_storage_class = ["MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"]
    condition_num_newer_versions = null
  }

  cors = {
    max_age_seconds = 3600
    rules = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        allowed_origins = ["*"]
        exposed_headers = ["*"]
        max_age_seconds = 3600
      }
    ]
  }

  logging = {
    log_bucket        = "example-log-bucket"
    log_object_prefix = "logs"
  }

  versioning_config = {
    enabled = true
  }

  website = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
```