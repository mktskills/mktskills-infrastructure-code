# CodeBuild Pipeline Module

## Module Code
*gcp_pipeline*

## Description

This Terraform module sets up a Google Cloud Build pipeline that is triggered by a code repository. The pipeline can be configured with multiple steps, custom environment variables, and build-time substitutions. It can also support cross-project access to manage resources in separate Google Cloud projects, both for building and deploying.

The google_cloudbuild_trigger resource creates a Cloud Build trigger in the specified project and location, listening for changes to the repository specified by the repo_name and repo_branch_regexp variables. The build is then executed using the defined steps, with substitutions and environment variables provided.

The data.google_project data source retrieves the current project's information, which is used to configure the Cloud Build service account for cross-project access. The google_project_iam_binding resources, cross_project_access_build and cross_project_access_deploy, set up the necessary IAM policies to grant the Cloud Build service account access to manage resources in the specified projects based on provided IAM roles and conditions.

This module makes it easy to create customizable Cloud Build pipelines that can be triggered automatically, managing your resources effectively and supporting cross-project access for building and deploying your applications.

## Usage Examples

```
module "codebuild_pipeline" {
  source            = "./modules/gcp_pipeline"
  project_id        = "your-project-id"
  
  location          = "us-central1"
  pipeline_id       = "example"
  description       = "Example CodeBuild Pipeline"
  service_account   = "your-service-account"
  repo_name         = "your-repo-name"
  repo_branch_regexp = "^main$"
  steps             = [
    { name = "gcr.io/cloud-builders/docker", args = ["build", "-t", "gcr.io/$PROJECT_ID/my-image:$SHORT_SHA", "."] }
  ]
  deploy_policies   = [
    { role = "roles/storage.admin", expression = "request.service_account_email == '${google_project.project.number}@cloudbuild.gserviceaccount.com'" }
  ]
}
```

```
module "codebuild_pipeline_cross_project" {
  source            = "./modules/gcp_pipeline"
  project_id        = "your-project-id"
  
  deploy_project_id = "your-deploy-project-id"
  location          = "us-central1"
  pipeline_id       = "example-cross"
  description       = "Example CodeBuild Pipeline with Cross-Project Access"
  service_account   = "your-service-account"
  repo_name         = "your-repo-name"
  repo_branch_regexp = "^main$"
  steps             = [
    { name = "gcr.io/cloud-builders/docker", args = ["build", "-t", "gcr.io/$PROJECT_ID/my-image:$SHORT_SHA", "."] }
  ]
  deploy_policies   = [
    { role = "roles/storage.admin", expression = "request.service_account_email == '${google_project.project.number}@cloudbuild.gserviceaccount.com'" }
  ]
}
```

```
module "codebuild_pipeline_custom_steps" {
  source            = "./modules/gcp_pipeline"
  project_id        = "your-project-id"
  
  location          = "us-central1"
  pipeline_id       = "example-custom"
  description       = "Example CodeBuild Pipeline with Custom Steps"
  service_account   = "your-service-account"
  repo_name         = "your-repo-name"
  repo_branch_regexp = "^main$"
  steps             = [
    { name = "gcr.io/cloud-builders/npm", args = ["install"] },
    { name = "gcr.io/cloud-builders/npm", args = ["run", "build"] },
    { name = "g-builders/docker", args = ["build", "-t", "gcr.io/$PROJECT_ID/my-image:$SHORT_SHA", "."] }
  ]
  deploy_policies   = [
    { role = "roles/storage.admin", expression = "request.service_account_email == '${google_project.project.number}@cloudbuild.gserviceaccount.com'" }
  ]
}
```
