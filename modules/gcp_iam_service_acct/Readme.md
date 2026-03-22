# IAM Service Account Module

## Module Code
*gcp_iam_service_acct*

## Description

This Terraform module creates and manages Google Cloud IAM service accounts with comprehensive role and permission management. The module supports assigning predefined roles both in the service account's project and in foreign projects, creating custom roles with specific permissions, and managing service account impersonation permissions.

Key features include:
- Creation of service accounts with configurable display name and description
- Assignment of predefined IAM roles in the service account's project
- Cross-project role assignments to foreign projects
- Custom role creation with specific IAM policies/permissions
- Service account user and token creator role assignments for impersonation
- Support for service account key creation and management

## Usage Examples

Create a basic service account with roles:

```
module "basic_service_account" {
  source = "./modules/gcp_iam_service_acct"

  project_id                    = "my-gcp-project"
  service_account_name          = "my-app-sa"
  service_account_display_name  = "My Application Service Account"
  service_account_description   = "Service account for my application"

  roles = [
    "roles/storage.objectViewer",
    "roles/bigquery.dataViewer"
  ]
}
```

Create a service account with custom permissions:

```
module "custom_sa" {
  source = "./modules/gcp_iam_service_acct"

  project_id                    = "my-gcp-project"
  service_account_name          = "custom-permissions-sa"
  service_account_display_name  = "Custom Permissions Service Account"
  service_account_description   = "Service account with custom IAM permissions"

  policies = [
    "storage.buckets.get",
    "storage.objects.list",
    "bigquery.datasets.get",
    "bigquery.tables.get"
  ]
}
```

Create a service account with foreign project access and impersonation:

```
module "multi_project_sa" {
  source = "./modules/gcp_iam_service_acct"

  project_id                    = "my-gcp-project"
  service_account_name          = "multi-project-sa"
  service_account_display_name  = "Multi-Project Service Account"
  service_account_description   = "Service account with access to multiple projects"

  roles = [
    "roles/storage.objectViewer"
  ]

  foreign_project_roles = [
    {
      project_id = "foreign-project-1"
      roles      = ["roles/bigquery.dataViewer", "roles/storage.objectAdmin"]
    },
    {
      project_id = "foreign-project-2"
      roles      = ["roles/dataflow.worker"]
    }
  ]

  members_token_creator = [
    "user:developer@example.com",
    "serviceAccount:ci-cd-sa@my-project.iam.gserviceaccount.com"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The ID of the project where the service account will be created. | `string` | n/a | yes |
| service_account_name | The unique name for the service account. | `string` | n/a | yes |
| service_account_display_name | The display name for the service account. | `string` | n/a | yes |
| service_account_description | The description for the service account. | `string` | n/a | yes |
| roles | The roles to be assigned to the service account in its own project. | `list(string)` | `[]` | no |
| foreign_project_roles | The roles to be assigned to the service account in foreign projects. Each entry contains a project_id and list of roles. | `list(object({ project_id=string, roles=list(string) }))` | `[]` | no |
| policies | A list of IAM permissions to be assigned to a custom role for the service account. Leave empty if no custom role is needed. | `list(string)` | `[]` | no |
| members | A list of members (users, groups, or service accounts) to be granted the serviceAccountUser role on this service account. | `list(string)` | `[]` | no |
| members_token_creator | A list of members to be granted both serviceAccountUser and serviceAccountTokenCreator roles for impersonation and token generation. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_account_email | The email address of the created service account. |
| service_account_id | The unique ID of the created service account. |
| custom_role_id | The ID of the created custom role if any policies were provided. Empty if no custom role was created. |
