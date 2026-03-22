##################################################
## CI/CD Pipelines - Backend (Cloud Run)
##################################################

locals {
  backend_build_step = {
    name = "gcr.io/cloud-builders/docker"
    args = [
      "build",
      "-t",
      "${local.env_main_region}-docker.pkg.dev/${local.project_id}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID",
      "--build-arg", "COMMIT_SHA=$COMMIT_SHA",
      "--build-arg", "BUILD_ID=$BUILD_ID",
      "--build-arg", "ENV=$_ENV",
      "--build-arg", "PROJECT_ID=$_DEPLOY_PROJECT_ID",
      "."
    ]
  }

  backend_push_step = {
    name = "gcr.io/cloud-builders/docker"
    args = [
      "push",
      "${local.env_main_region}-docker.pkg.dev/${local.project_id}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID"
    ]
  }

  backend_deploy_step = {
    name = "gcr.io/cloud-builders/gcloud"
    args = [
      "run", "deploy", "$_SERVICE_NAME",
      "--image=${local.env_main_region}-docker.pkg.dev/${local.project_id}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID",
      "--region=${local.env_main_region}",
      "--platform=managed",
      "--project=${local.project_id_prod}",
      "--service-account=$_SERVICE_ACCOUNT",
      "--allow-unauthenticated",
      "--ingress=internal-and-cloud-load-balancing",
      "--cpu-throttling",
      "--memory=$_CLOUDRUN_MEMORY",
      "--cpu=$_CLOUDRUN_VCPU",
      "--min-instances=$_CLOUDRUN_MIN_INSTANCES",
      "--max-instances=$_CLOUDRUN_MAX_INSTANCES",
    ]
  }
}

module "pipeline_backend_stage" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-backend-code-stage"
  env                = "stage"
  description        = "CI/CD pipeline for mktskills backend — stage branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^stage$"
  repo_name          = "mktskills/mktskills-backend-app"
  build_policies = [{
    role       = "roles/artifactregistry.writer"
    expression = "resource.name.startsWith(\"projects/${local.project_id}/locations/${local.env_main_region}/repositories/${local.backend_artifacts_repo}\")"
  }]
  deploy_project_id = local.project_id_prod
  deploy_policies = [{
    role       = "roles/run.developer"
    expression = "resource.name.startsWith(\"projects/${local.project_id_prod}/locations/${local.env_main_region}/services/crunserv-${local.project_folder_code}-backend-apiserver-stage\")"
  }]
  steps = [
    local.backend_build_step,
    local.backend_push_step,
    local.backend_deploy_step,
  ]
  env_vars = [
    "_IMAGE_NAME=mktskills-backend-apiserver",
    "_ENV=stage",
    "_DEPLOY_PROJECT_ID=${local.project_id_prod}",
    "_SERVICE_NAME=crunserv-${local.project_folder_code}-backend-apiserver-stage",
    "_SERVICE_ACCOUNT=sa-${local.project_folder_code}-backend-apiserver@${local.project_id_prod}.iam.gserviceaccount.com",
    "_CLOUDRUN_MEMORY=512Mi",
    "_CLOUDRUN_VCPU=1",
    "_CLOUDRUN_MIN_INSTANCES=0",
    "_CLOUDRUN_MAX_INSTANCES=3",
  ]
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}

module "pipeline_backend_prod" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-backend-code-prod"
  env                = "prod"
  description        = "CI/CD pipeline for mktskills backend — master branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^master$"
  repo_name          = "mktskills/mktskills-backend-app"
  build_policies = [{
    role       = "roles/artifactregistry.writer"
    expression = "resource.name.startsWith(\"projects/${local.project_id}/locations/${local.env_main_region}/repositories/${local.backend_artifacts_repo}\")"
  }]
  deploy_project_id = local.project_id_prod
  deploy_policies = [{
    role       = "roles/run.developer"
    expression = "resource.name.startsWith(\"projects/${local.project_id_prod}/locations/${local.env_main_region}/services/crunserv-${local.project_folder_code}-backend-apiserver-prod\")"
  }]
  steps = [
    local.backend_build_step,
    local.backend_push_step,
    local.backend_deploy_step,
  ]
  env_vars = [
    "_IMAGE_NAME=mktskills-backend-apiserver",
    "_ENV=prod",
    "_DEPLOY_PROJECT_ID=${local.project_id_prod}",
    "_SERVICE_NAME=crunserv-${local.project_folder_code}-backend-apiserver-prod",
    "_SERVICE_ACCOUNT=sa-${local.project_folder_code}-backend-apiserver@${local.project_id_prod}.iam.gserviceaccount.com",
    "_CLOUDRUN_MEMORY=1Gi",
    "_CLOUDRUN_VCPU=1",
    "_CLOUDRUN_MIN_INSTANCES=1",
    "_CLOUDRUN_MAX_INSTANCES=10",
  ]
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}
