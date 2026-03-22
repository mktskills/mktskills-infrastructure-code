# CDN Served Static Website Module

## Module Code
*gcp_cdn_website*

## Description

This Terraform module is designed to create and manage a website served through a Content Delivery Network (CDN) on Google Cloud Platform. The module provisions a Google Cloud Storage bucket to store the website's static content, and configures a global HTTP(S) load balancer to serve the content through the CDN. It supports automatic HTTP to HTTPS redirection, custom subdomains, and SSL certificates managed by Google.

The module also allows for advanced CDN configuration, including cache control, request coalescing, bypassing cache based on request headers, and setting up cache key policies. You can further configure negative caching policies for different HTTP status codes, helping to reduce latency and improve user experience. This module is ideal for organizations looking to serve their websites with high performance, security, and global availability.

By using this Terraform module, you can ensure that your website's static content is delivered quickly and securely to users around the world. It provides an easy-to-use and highly configurable solution for deploying and managing websites on Google Cloud Platform, leveraging the benefits of the Google Cloud CDN.

## Usage Examples

Create a simple website with default CDN settings:

```
module "simple_website" {
  source              = "./modules/gcp_cdn_website"
  project_id          = "my-gcp-project"
  website_id          = "simple-website"
  bucket_location     = "us-central1"
  main_page           = "index.html"
  not_found_page      = "404.html"
  dns_managed_zone_name = "my-dns-zone"
  subdomains          = ["www"]
}
```

Create a website with custom CDN policy:

```
module "custom_cdn_website" {
  source              = "./modules/gcp_cdn_website"
  project_id          = "my-gcp-project"
  website_id          = "custom-cdn-website"
  bucket_location     = "us-central1"
  main_page           = "index.html"
  not_found_page      = "404.html"
  dns_managed_zone_name = "my-dns-zone"
  subdomains          = ["www"]
  cdn_policy          = {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
    negative_caching_policy = [
      {
        code = 404
        ttl  = 10
      },
      {
        code = 301
        ttl  = 300
      }
    ]
  }
}
```

Create a website with multiple subdomains:

```
module "multi_subdomain_website" {
  source              = "./modules/gcp_cdn_website"
  project_id          = "my-gcp-project"
  website_id          = "multi-subdomain-website"
  bucket_location     = "us-central1"
  main_page           = "index.html"
  not_found_page      = "404.html"
  dns_managed_zone_name = "my-dns-zone"
  subdomains          = ["www", "blog", "store"]
}
```