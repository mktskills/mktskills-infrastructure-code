# devstage

Placeholder for dev/stage environment resources.

When the GCP project is split (devstage project created), move dev/stage resources here following the same structure as `prod/`:
- `cdn_websites/` — staging CDN bucket + domain
- `lb_backends/` — staging load balancer
- `iam/` — staging service accounts
- `secrets/` — staging secrets

Update `cross/main.tf` to pass `project_id_devstage` to the build modules.
