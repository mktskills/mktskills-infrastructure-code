##################################################
## CI/CD Pipelines - Backend (Cloud Run)
##################################################

locals {
  _set_secrets = join(",", [
    "SECRET_CLERK=secret-${local.project_folder_code}-clerk-$_ENV:latest",
    "SECRET_DB=secret-${local.project_folder_code}-db-$_ENV:latest",
    "SECRET_SESSION=secret-${local.project_folder_code}-session-$_ENV:latest",
    "SECRET_AIMODELS=secret-${local.project_folder_code}-aimodels-$_ENV:latest",
    "SECRET_INTEGRATIONS=secret-${local.project_folder_code}-integrations-$_ENV:latest",
    "SECRET_DAYTONA=secret-${local.project_folder_code}-daytona-$_ENV:latest",
    "SECRET_MESSAGING=secret-${local.project_folder_code}-messaging-$_ENV:latest",
  ])

  backend_build_step = {
    name = "gcr.io/cloud-builders/docker"
    args = [
      "build",
      "-t",
      "${local.env_main_region}-docker.pkg.dev/${local.project_id_cross}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID",
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
      "${local.env_main_region}-docker.pkg.dev/${local.project_id_cross}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID"
    ]
  }

  backend_deploy_step = {
    name = "gcr.io/cloud-builders/gcloud"
    args = [
      "run", "deploy", "$_SERVICE_NAME",
      "--image=${local.env_main_region}-docker.pkg.dev/${local.project_id_cross}/${local.backend_artifacts_repo}/$${_IMAGE_NAME}:$COMMIT_SHA-$BUILD_ID",
      "--region=${local.env_main_region}",
      "--platform=managed",
      "--project=$_DEPLOY_PROJECT_ID",
      "--service-account=$_SERVICE_ACCOUNT",
      "--no-allow-unauthenticated",
      "--ingress=internal-and-cloud-load-balancing",
      "--cpu-throttling",
      "--memory=$_CLOUDRUN_MEMORY",
      "--cpu=$_CLOUDRUN_VCPU",
      "--min-instances=$_CLOUDRUN_MIN_INSTANCES",
      "--max-instances=$_CLOUDRUN_MAX_INSTANCES",
      "--set-secrets=${local._set_secrets}",
      "--update-env-vars=FRONTEND_URL=$_FRONTEND_URL,API_BASE_URL=$_API_BASE_URL,DEBUG=$_DEBUG",
      "--update-env-vars=^|^CORS_ORIGINS=$_CORS_ORIGINS",
    ]
  }
}

module "pipeline_backend_dev" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id_cross

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-backend-code-dev"
  service_account_id = "cbld-${local.project_folder_code}-backend-dev"
  env                = "dev"
  description        = "CI/CD pipeline for mktskills backend — dev branch"
  repo_type          = "GITHUB_V2"
  v2_repo_id         = local.backend_app_repo_id
  repo_branch_regexp = "^dev$"
  repo_name          = "mktskills/mktskills-backend-app"
  build_policies = [{
    role = "roles/logging.logWriter"
  }]
  write_artifacts_repos         = ["${local.project_id_cross}/${local.env_main_region}/${local.backend_artifacts_repo}"]
  logging                       = "CLOUD_LOGGING_ONLY"
  deploy_project_id             = local.project_id_devstage
  deploy_act_as_service_account = ["${local.project_folder_code}-backend-api-dev@${local.project_id_devstage}.iam.gserviceaccount.com"]
  deploy_policies = [{
    role = "roles/run.admin"
  }]
  steps = [
    local.backend_build_step,
    local.backend_push_step,
    local.backend_deploy_step,
  ]
  substitutions = {
    _IMAGE_NAME             = "mktskills-backend-api"
    _ENV                    = "dev"
    _DEPLOY_PROJECT_ID      = local.project_id_devstage
    _SERVICE_NAME           = "crunserv-${local.project_folder_code}-backend-api-dev"
    _SERVICE_ACCOUNT        = "${local.project_folder_code}-backend-api-dev@${local.project_id_devstage}.iam.gserviceaccount.com"
    _CLOUDRUN_MEMORY        = "1Gi"
    _CLOUDRUN_VCPU          = "1"
    _CLOUDRUN_MIN_INSTANCES = "0"
    _CLOUDRUN_MAX_INSTANCES = "3"
    _FRONTEND_URL           = "https://www-o8styhv7948sg53i.mktskills.ai"
    _API_BASE_URL           = "https://api-o8styhv7948sg53i.mktskills.ai"
    _CORS_ORIGINS           = jsonencode(["https://www-o8styhv7948sg53i.mktskills.ai"])
    _DEBUG                  = "false"
  }
  env_vars     = []
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}

module "pipeline_backend_prod" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id_cross

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-backend-code-prod"
  service_account_id = "cbld-${local.project_folder_code}-backend-prod"
  env                = "prod"
  description        = "CI/CD pipeline for mktskills backend — master branch"
  repo_type          = "GITHUB_V2"
  v2_repo_id         = local.backend_app_repo_id
  repo_branch_regexp = "^master$"
  repo_name          = "mktskills/mktskills-backend-app"
  build_policies = [{
    role = "roles/logging.logWriter"
  }]
  write_artifacts_repos         = ["${local.project_id_cross}/${local.env_main_region}/${local.backend_artifacts_repo}"]
  logging                       = "CLOUD_LOGGING_ONLY"
  deploy_project_id             = local.project_id_prod
  deploy_act_as_service_account = ["${local.project_folder_code}-backend-api-prod@${local.project_id_prod}.iam.gserviceaccount.com"]
  deploy_policies = [{
    role = "roles/run.admin"
  }]
  steps = [
    local.backend_build_step,
    local.backend_push_step,
    local.backend_deploy_step,
  ]
  substitutions = {
    _IMAGE_NAME             = "mktskills-backend-api"
    _ENV                    = "prod"
    _DEPLOY_PROJECT_ID      = local.project_id_prod
    _SERVICE_NAME           = "crunserv-${local.project_folder_code}-backend-api-prod"
    _SERVICE_ACCOUNT        = "${local.project_folder_code}-backend-api-prod@${local.project_id_prod}.iam.gserviceaccount.com"
    _CLOUDRUN_MEMORY        = "1Gi"
    _CLOUDRUN_VCPU          = "1"
    _CLOUDRUN_MIN_INSTANCES = "1"
    _CLOUDRUN_MAX_INSTANCES = "10"
    _FRONTEND_URL           = "https://www.mktskills.ai"
    _API_BASE_URL           = "https://api.mktskills.ai"
    _CORS_ORIGINS           = jsonencode(["https://www.mktskills.ai"])
    _DEBUG                  = "false"
  }
  env_vars     = []
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}
