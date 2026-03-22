# Source Repository Module

## Module Code
*gcp_repository*

## Description

This Terraform module creates a Google Cloud Source Repository and configures optional Pub/Sub notifications for repository changes. The repository supports version control for your code, and the Pub/Sub integration helps keep external systems informed about changes.

## Usage Cases

Create a Google Cloud Source Repository without Pub/Sub notifications:

```
module "source_repository_no_pubsub" {
  source                  = "./modules/gcp_repository"
  project_id              = "my-project"
  
  repository_id           = "my-repo-no-pubsub"
  publish_changes         = false
}
```

Create multiple Google Cloud Source Repositories with Pub/Sub notifications:

```
module "source_repository_one" {
  source                  = "./modules/gcp_repository"
  project_id              = "my-project"
  
  repository_id           = "repo-one"
  publish_changes         = true
  publishing_service_account = "my-service-account@example.com"
}

module "source_repository_two" {
  source                  = "./modules/gcp_repository"
  project_id              = "my-project"

  repository_id           = "repo-two"
  publish_changes         = true
  publishing_service_account = "my-service-account@example.com"
}
```