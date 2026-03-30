# Project Structure — infra

This repo is infrastructure-as-code for mktskills.ai on GCP.

## Layout

```text
infra/
├── modules/   # reusable Terraform building blocks
└── scripts/   # actual stack entrypoints
    ├── cross/      # shared CI/CD + repo + DNS/storage plumbing
    ├── prod/       # production runtime resources
    └── devstage/   # dev/stage runtime resources
```

## Modules vs stacks

### `modules/`

Reusable libraries:

- Artifact Registry
- CDN website
- DNS zone
- IAM helpers
- load-balancer backend
- Cloud Build pipeline
- repository connection
- Secret Manager
- storage bucket

Never run `terraform plan/apply` from here.

### `scripts/`

These are the stack entrypoints and the only safe places to run Terraform commands.

- `scripts/cross/` — shared repos, Artifact Registry, Cloud Build, DNS/storage support
- `scripts/prod/` — production-facing runtime wiring
- `scripts/devstage/` — non-prod runtime wiring

## Environment shape

This repo already documents environments in code:

- stack folders
- branch-trigger pipeline definitions
- secret names
- service names
- project locals

Do not create a second “truth” that drifts from Terraform.
