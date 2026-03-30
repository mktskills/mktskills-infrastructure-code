# CI/CD — infra

> **Authoritative source**: `.github/workflows/ci.yml` defines CI. The Terraform stacks themselves define deployment. If these disagree, the live state decides reality.

## CI in this repo

GitHub Actions runs on every PR and push to `master`/`dev`. Four parallel jobs:

| Job | Tool | What it catches |
|-----|------|-----------------|
| fmt | `terraform fmt -check` | Formatting drift |
| validate | `terraform validate` | Syntax errors, broken references (per stack, `-backend=false`) |
| tflint | TFLint + GCP ruleset | Bad patterns, unused variables, provider-specific issues |
| tfsec | tfsec | Security misconfigurations, open resources, policy violations |

Config: `.tflint.hcl` at repo root (GCP plugin, recommended preset).

## CD

There is no CD pipeline for this repo. Terraform changes are applied manually via `scripts/tf` after review:

```bash
scripts/tf cross plan
scripts/tf prod plan
scripts/tf devstage plan
```

`apply` is a human decision, not an automated one.

## Change discipline

If you change:

- module interfaces
- resource names or IDs
- secret names
- service account names
- branch triggers in pipeline definitions

check downstream impact on `backend/` and `web/` repos. Infrastructure changes can silently break deployment without failing any CI check.
