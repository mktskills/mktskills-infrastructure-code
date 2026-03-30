# AGENTS.md — mktskills.ai Infrastructure

This is the Terraform repo for mktskills.ai infrastructure.

There is no separate CI/CD app layer here to document. This repo **is** the environment and deployment wiring.

## Quick Reference

- **Project structure:** [`./.agents/PROJECT_STRUCTURE.md`](./.agents/PROJECT_STRUCTURE.md)
- **Git & PR conventions:** [`./.agents/GIT_PR_CONVENTIONS.md`](./.agents/GIT_PR_CONVENTIONS.md)

## Terraform Rules

**Only run Terraform commands from a stack folder.**

Valid working directories:
- `scripts/cross/` — shared CI/CD infrastructure (Artifact Registry, Cloud Build, DNS, IAM, Storage)
- `scripts/prod/` — production runtime (Cloud Run, CDN, LB, IAM, secrets)
- `scripts/devstage/` — dev runtime (mirrors prod, targets devstage project)

Never run `terraform` from:
- `modules/` — these are libraries, not stacks
- `scripts/cross/build_tools/`, `scripts/prod/cdn_websites/`, etc. — these are sub-modules called by their parent stack

```bash
# Correct
cd infra/scripts/cross && terraform plan --account info@scidive.ai

# Wrong — will fail or corrupt state
cd infra/scripts/cross/build_tools && terraform plan
cd infra/modules/gcp_pipeline && terraform plan
```

## Stack Overview

| Stack | Folder | GCS state prefix | Project (current) |
|---|---|---|---|
| cross | `scripts/cross/` | `cross/` | `mktskills-prod` |
| prod | `scripts/prod/` | `prod/` | `mktskills-prod` |
| devstage | `scripts/devstage/` | `devstage/` | `mktskills-prod` |

All three currently target `mktskills-prod`. When projects are split, update the `project_id_*` locals in each stack's `main.tf` — no resource references need changing.

## GCP / gcloud

Always pass explicit flags:

```bash
gcloud <command> --account info@scidive.ai --project mktskills-prod
```

Terraform uses application default credentials (ADC), not `--account`. Use the `scripts/tf` wrapper — it fetches a fresh token automatically and forwards all arguments:

```bash
# From infra/ root
scripts/tf cross init
scripts/tf prod plan
scripts/tf devstage apply -target=module.devstage_cdn
```

## Pre-apply Checklist

1. GCS state bucket exists: `gsutil ls gs://csbuck-mktskills-infrastructure-tfstate`
2. GitHub connection authorized in Cloud Build Console (one-time, manual)
3. `terraform init` completed in the target stack folder
4. `terraform plan` reviewed before `apply`

## Practical Rules

- Treat `scripts/cross/` as shared deployment plumbing, not “just another env”.
- Treat `scripts/prod/` and `scripts/devstage/` as the runtime stacks.
- If you change service names, branch triggers, Artifact Registry repos, or secret names, check the downstream impact on `backend/`, `web/`, and root docs.
- Do not add environment claims to docs that are not backed by Terraform.
