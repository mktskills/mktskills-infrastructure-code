output "bucket_url" {
  description = "The URL of the created Cloud Storage bucket"
  value       = google_storage_bucket.bucket.url
}

output "bucket_name" {
  description = "The name of the created Cloud Storage bucket"
  value       = google_storage_bucket.bucket.name
}
