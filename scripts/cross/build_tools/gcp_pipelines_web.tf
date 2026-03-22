##################################################
## CI/CD Pipelines - Web (Astro + Vite)
##################################################

locals {
  web_pipeline_steps = [
    {
      name   = "node:22"
      script = <<EOT
#!/usr/bin/env bash
set -e
export COMMIT_SHA="$COMMIT_SHA"

# Install pnpm (project uses pnpm; node:22 ships with npm/corepack)
npm install -g pnpm

# Inject Vite build-time env vars (baked into the static JS bundle)
export VITE_API_URL="https://$API_HOST"
export VITE_CLERK_PUBLISHABLE_KEY="$CLERK_PUBLISHABLE_KEY"

# Build Astro site (public/SEO pages) -> ../dist/
cd site
pnpm install --frozen-lockfile
pnpm run build

# Build Vite React app (authenticated app) -> ../dist/app/
cd ../app
pnpm install --frozen-lockfile
pnpm run build
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
gsutil -m cp "$APP_ID"_"$COMMIT_SHA"_"$BUILD_DATETIME"_"$BUILD_ID".zip gs://"$ARTIFACTS_BUCKET_NAME"/"$APP_ID"/$APP_ENV/
      EOT
    }
  ]
}

module "pipeline_web_app_dev" {
  source                             = "../../../modules/gcp_pipeline"
  map_base_substitutions_to_env_vars = true
  providers = {
    google = google
  }
  project_id = local.project_id

  location           = local.env_main_region
  pipeline_id        = "${local.project_folder_code}-webapp-code-dev"
  env                = "dev"
  description        = "CI/CD pipeline for mktskills web app — dev branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^dev$"
  repo_name          = "mktskills/mktskills-web-app"
  deploy_project_id  = local.project_id_prod
  deploy_policies = [{
    role       = "roles/storage.objectAdmin"
    expression = "resource.name.startsWith(\"projects/_/buckets/csbuck-${local.project_folder_code}-webapp-website-dev\")"
  }]
  steps = local.web_pipeline_steps
  env_vars = [
    "BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-website-dev",
    "APP_ENV=dev",
    "APP_ID=${local.project_folder_code}_webapp",
    "ARTIFACTS_BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-artifacts-cross",
    "API_HOST=api-dev.mktskills.ai",
    "CLERK_PUBLISHABLE_KEY=pk_test_REPLACE_WITH_DEV_KEY",
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
  description        = "CI/CD pipeline for mktskills web app — main branch"
  repo_type          = "GITHUB"
  repo_branch_regexp = "^master$"
  repo_name          = "mktskills/mktskills-web-app"
  deploy_project_id  = local.project_id_prod
  deploy_policies = [{
    role       = "roles/storage.objectAdmin"
    expression = "resource.name.startsWith(\"projects/_/buckets/csbuck-${local.project_folder_code}-webapp-website-prod\")"
  }]
  steps = local.web_pipeline_steps
  env_vars = [
    "BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-website-prod",
    "APP_ENV=prod",
    "APP_ID=${local.project_folder_code}_webapp",
    "ARTIFACTS_BUCKET_NAME=csbuck-${local.project_folder_code}-webapp-artifacts-cross",
    "API_HOST=api.mktskills.ai",
    "CLERK_PUBLISHABLE_KEY=pk_live_REPLACE_WITH_PROD_KEY",
  ]
  timeout      = "900s"
  machine_type = "E2_HIGHCPU_8"
}
