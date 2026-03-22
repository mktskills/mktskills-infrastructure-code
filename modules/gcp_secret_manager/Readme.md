# GCP Secret Manager Module

This module creates a secret in Google Cloud Secret Manager, adds an initial version with specified data, and grants access permissions.

## Purpose

This module provisions a secret in Google Cloud Secret Manager, optionally initializes it with a secret value, and configures IAM policies to control access to the secret.

## Resources Created

- `google_secret_manager_secret`: Provisions the secret container with automatic replication.
- `google_secret_manager_secret_iam_member`: Grants `roles/secretmanager.secretAccessor` to each principal listed in `var.read_principals`.
- `google_secret_manager_secret_version` (conditional): Adds the initial secret version if `var.secret_data` is provided.

## Usage

```terraform
module "secret_manager" {
  source  = "./modules/gcp_secret_manager"
  project_id    = var.project_id
  secret_id     = "my-application-secret"
  secret_data   = "super-secret-value"
  read_principals = [
    "serviceAccount:my-service-account@my-project.iam.gserviceaccount.com",
  ]
}
```

## Inputs

- `project_id`: GCP Project ID.
- `secret_id`: Unique identifier for the secret.
- `secret_data` (optional): The secret content for the initial version.
- `read_principals`: List of principals (e.g., `serviceAccount:email`) to grant read access.

## Outputs

This module does not explicitly define any outputs in its `outputs.tf` file, but the created secret can be referenced by its ID or name in other Terraform configurations.
