# IAM Members Binding

## Module Code
*gcp_iam_members_binding*

## Description

This Terraform module manages IAM bindings with conditional policies for users, groups, service accounts, and domains in a Google Cloud Project. The module is highly flexible and accepts a list of IAM roles with their corresponding condition titles and expressions, as well as lists of users, groups, service accounts, and domains. It then applies the specified IAM roles and conditions to each of the provided principals, ensuring that each principal is granted the appropriate access based on the roles and conditions specified.

# Usage Examples

Basic Viewer Role

```
module "basic_viewer_role" {
  source = "./modules/gcp_iam_members_binding"

  project_id = "<YOUR-GCP-PROJECT-ID>"

  users = [
    "user1@example.com",
    "user2@example.com",
  ]

  groups = [
    "group1@example.com",
  ]

  roles_with_conditions = [
    {
      role                = "roles/viewer"
      condition_title     = null
      condition_expression = null
    },
  ]
}
```

Restricted Storage Admin

```
module "restricted_storage_admin" {
  source = "./modules/gcp_iam_members_binding"

  project_id = "<YOUR-GCP-PROJECT-ID>"

  users = [
    "user1@example.com",
    "user2@example.com",
  ]

  serviceAccounts = [
    "my-service-account@<YOUR-GCP-PROJECT-ID>.iam.gserviceaccount.com",
  ]

  roles_with_conditions = [
    {
      role                = "roles/storage.admin"
      condition_title     = "read_only"
      condition_expression = "request.operation != 'write'"
    },
  ]
}
```

Custom Editor Role with No Deletion

```
module "custom_editor_role_no_deletion" {
  source = "./modules/gcp_iam_members_binding"

  project_id = "<YOUR-GCP-PROJECT-ID>"

  users = [
    "user1@example.com",
    "user2@example.com",
  ]

  groups = [
    "group1@example.com",
  ]

  roles_with_conditions = [
    {
      role                = "roles/editor"
      condition_title     = "no_delete"
      condition_expression = "request.operation != 'delete'"
    },
  ]
}
```