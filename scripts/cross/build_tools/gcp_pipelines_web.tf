##################################################
## CI/CD Pipelines - Web (Astro + Vite)
##################################################

locals {
  web_pipeline_steps_stage = [
    {
      name   = "node:22"
      script = <<EOT
#!/usr/bin/env bash
set -e
export COMMIT_SHA="$COMMIT_SHA"

# Build Astro site (public/SEO pages) -> ../dist/
cd site
npm ci
npm run build

# Build Vite React app (authenticated app) -> ../dist/app/
cd ../app
npm ci
npm run build
      EOT
    },
    {
      name   = "gcr.io/cloud-builders/gsutil"
      script = <<EOT
#!/usr/bin/env bash
set -e
BUILD_DATETIME=$(date +%Y-%m-%dT%H-%M-%S%z)

echo "$COMMIT_SHA" > dist/commit_id.txt
echo "$APP_ID"_"$COMMIT_SHA"_"$BUILD_DATETIME"_"$BUILD_ID".zip > dist/artifact_id.txt

gsutil -m rsync -r -d ./dist gs://$BUCKET_NAME

# Fix content-type for extensionless HTML files (Astro routes)
gsutil ls -r gs://$BUCKET_NAME/** > files_in_root
while read file; do
  if [[ "$file" =~ ^.*/[^./]*$ ]]; then
    gsutil setmeta -h "Content-Type:text/html" "$file"
  fi
done < files_in_root

# Archive artifact
zip -r -9 "$APP_ID"_"$COMMIT_SHA"_"$BUILD_DATETIME"_"$BUILD_ID".zip dist/*
gsutil -m cp "$APP_ID"_"$COMMIT_SHA"_"$BUILD_DATETIME"_"$BUILD_ID".zip gs://"$ARTIFACTS_BUCKET_NAME"/"$APP_ID"/stage/
      EOT
    }
  ]

  web_pipeline_steps_prod = [
    {
      name   = "gcr.io/cloud-builders/gsutil"
      script = <<EOT
#!/usr/bin/env bash
set -e
STAGE_COMMIT_SHA=$(cat commit_source.txt)
gsutil -m cp gs://"$ARTIFACTS_BUCKET_NAME"/"$APP_ID"/stage/"$APP_ID"_"$STAGE_COMMIT_SHA"_* .
LATEST_FILE=$(ls -1 "$APP_ID"_"$STAGE_COMMIT_SHA"_* | sort -t "_" -k3,3 | tail -n 1)
mkdir -p artifact
unzip $LATEST_FILE -d ./artifact
DEPLOY_DATETIME=$(date +%Y-%m-%dT%H-%M-%S%z)

gsutil -m rsync -r -d ./artifact/dist gs://$BUCKET_NAME

gsutil ls -r gs://$BUCKET_NAME/** > files_in_root
while read file; do
  if [[ "$file" =~ ^.*/[^./]*$ ]]; then
    gsutil setmeta -h "Content-Type:text/html" "$file"
  fi
done < files_in_root

zip -r -9 "$APP_ID"_"$STAGE_COMMIT_SHA"_"$DEPLOY_DATETIME"_"$BUILD_ID".zip ./artifact/*
gsutil -m cp "$APP_ID"_"$STAGE_COMMIT_SHA"_"$DEPLOY_DATETIME"_"$BUILD_ID".zip gs://"$ARTIFACTS_BUCKET_NAME"/"$APP_ID"/prod/
      EOT
    }
  ]
}

module "pipeline_web_app_stage" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-webapp-code-stage"
  env                = "stage"
  description        = "CI/CD pipeline for mktskills web app — stage branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^stage$"
  repo_name          = "mktskills/mktskills-web-app"
  deploy_project_id  = local.project_id_prod
  deploy_policies = [{
    role       = "roles/storage.objectAdmin"
    expression = "resource.name.startsWith(\"projects/_/buckets/csbuck-${local.project_folder_code}-webapp-website-stage\")"
  }]
  steps = local.web_pipeline_steps_stage
  env_vars = [
    "BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-website-stage",
    "APP_ENV=stage",
    "APP_ID=${local.project_folder_code}_webapp",
    "ARTIFACTS_BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-artifacts-cross",
    "API_HOST=api-stage.mktskills.ai",
  ]
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}

module "pipeline_web_app_prod" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-webapp-code-prod"
  env                = "prod"
  description        = "CI/CD pipeline for mktskills web app — prod branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^master$"
  repo_name          = "mktskills/mktskills-web-app"
  deploy_project_id  = local.project_id_prod
  deploy_policies = [{
    role       = "roles/storage.objectAdmin"
    expression = "resource.name.startsWith(\"projects/_/buckets/csbuck-${local.project_folder_code}-webapp-website-prod\")"
  }]
  steps   = local.web_pipeline_steps_prod
  env_vars = [
    "BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-website-prod",
    "APP_ENV=prod",
    "APP_ID=${local.project_folder_code}_webapp",
    "ARTIFACTS_BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-artifacts-cross",
    "API_HOST=api.mktskills.ai",
  ]
  ignored_files = ["commit_source.txt"]
}
