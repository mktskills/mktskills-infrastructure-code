# Git & PR Conventions — infra

Use Conventional Commits:

```text
<type>: <description>
```

Examples:

- `chore: add infra agent reference docs`
- `fix: correct backend service account binding`
- `feat: add stage web pipeline`

## Branch naming

Use clear prefixes:

- `feat/`
- `fix/`
- `chore/`
- `docs/`
- `refactor/`

## PR expectations

Infra PRs should include:

### Summary

- what changed
- why it changed

### Impact

- which stack(s) are affected
- whether service names, secrets, branches, or deploy paths changed

### Verification

- `terraform plan` target(s) reviewed
- any manual follow-up needed in GCP/GitHub connections

## Rule of thumb

If a Terraform change affects backend or web deployment assumptions, say so explicitly. Silent infra coupling is how teams create accidental outages with very professional-looking PRs.
