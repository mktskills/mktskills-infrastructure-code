# Load Balancer with Serverless Backend Module

## Module Code
*gcp_lb_backend*

## Description

This Terraform module deploys a fully-managed Google Cloud Load Balancer to serve Cloud Run instances. The module automatically handles the creation of DNS records, SSL certificates, and network endpoint groups for the specified backends. It configures an external HTTP(S) load balancer to forward incoming traffic to the appropriate backend service based on the provided configuration.

The google_compute_global_address resource reserves an IP address for the load balancer, and the google_dns_managed_zone data source retrieves the necessary information about the DNS managed zone. The google_dns_record_set resource creates A records for each specified subdomain, pointing to the reserved IP address.

The module creates a managed SSL certificate for the load balancer using the google_compute_managed_ssl_certificate resource. It also sets up a google_compute_region_network_endpoint_group for each serverless backend, allowing the load balancer to forward traffic to Cloud Functions, Cloud Run, and App Engine services.

Finally, the module creates a google_compute_backend_service for the serverless backends, a google_compute_url_map for HTTPS traffic, a google_compute_target_https_proxy, and a google_compute_global_forwarding_rule for HTTPS traffic, tying everything together into a functional load balancer.

# Usage Examples

```
module "load_balancer_cloudrun" {
  source = "./gcp_lb_backend"
  project_id               = "your-project-id"
  
  backend_id               = "example"
  dns_managed_zone_name    = "example-dns-zone"
  subdomains               = ["api"]
  serverless_backends      = [
    { name = "example-backend", region = "us-central1", cloud_run_name = "your-cloud-run-service" }
  ]
}
```

```
module "load_balancer_multiple_backends" {
  source = "./gcp_lb_backend"
  project_id               = "your-project-id"
  
  backend_id               = "example-multi"
  dns_managed_zone_name    = "example-dns-zone"
  subdomains               = ["backend1", "backend2"]
  serverless_backends      = [
    { name = "backend1", region = "us-central1", cloud_run_name = "your-cloud-run-service1" },
    { name = "backend2", region = "us-central1", cloud_run_name = "your-cloud-run-service2" }
  ]
}
```

```
module "load_balancer_mixed_backends" {
  source = "./gcp_lb_backend"
  project_id               = "your-project-id"

  backend_id               = "example-mixed"
  dns_managed_zone_name    = "example-dns-zone"
  subdomains               = ["backend1", "backend2", "backend3"]
  serverless_backends      = [
    { name = "backend1", region = "us-central1", cloud_run_name = "your-cloud-run-service1" },
    { name = "backend2", region = "us-central1", cloud_function_name = "your-cloud-function" },
    { name = "backend3", region = "us-central1", appengine_service = "default", appengine_version_id = "your-version-id" }
  ]
}
```