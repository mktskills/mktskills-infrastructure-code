resource "google_storage_bucket" "bucket" {
  provider = google
  project  = var.project_id
  
  name                        = "csbuck-${var.bucket_name}"
  location                    = var.location
  storage_class               = var.storage_class
  force_destroy               = var.force_destroy

  dynamic "versioning" {
    for_each = var.versioning != null ? [1] : []
    content {
      enabled = var.versioning
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type = lifecycle_rule.value.action_type
        storage_class = lookup(lifecycle_rule.value, "action_storage_class", null)
      }
      condition {
        age                       = lookup(lifecycle_rule.value, "condition_age", null)
        created_before            = lookup(lifecycle_rule.value, "condition_created_before", null)
        with_state                = lookup(lifecycle_rule.value, "condition_with_state", null)
        matches_storage_class     = lookup(lifecycle_rule.value, "condition_matches_storage_class", [])
        matches_prefix            = lookup(lifecycle_rule.value, "condition_matches_prefix", [])
        matches_suffix            = lookup(lifecycle_rule.value, "condition_matches_suffix", [])
        num_newer_versions        = lookup(lifecycle_rule.value, "condition_num_newer_versions", null)
        custom_time_before        = lookup(lifecycle_rule.value, "condition_custom_time_before", null)
        days_since_custom_time    = lookup(lifecycle_rule.value, "condition_days_since_custom_time", null)
        days_since_noncurrent_time= lookup(lifecycle_rule.value, "condition_days_since_noncurrent_time", null)
        noncurrent_time_before    = lookup(lifecycle_rule.value, "condition_noncurrent_time_before", null)

      }
    }
  }

  dynamic "encryption" {
    for_each = var.default_kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.default_kms_key_name
    }
  }

  dynamic "cors" {
    for_each = var.cors_rules
    content {
      origin = lookup(cors.value, "origin", null)
      method = lookup(cors.value, "method", null)
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [1] : []
    content {
      retention_period = var.retention_policy.retention_period
      is_locked = lookup(var.retention_policy, "is_locked", false)
    }
  }

  dynamic "logging" {
    for_each = var.logging != null ? [1] : []
    content {
      log_bucket = var.logging.log_bucket
      log_object_prefix = var.logging.log_object_prefix
    }
  }

  dynamic "website" {
    for_each = var.website != null ? [1] : []
    content {
      main_page_suffix = var.website.main_page_suffix
      not_found_page = var.website.not_found_page
    }
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  provider = google
  count    = var.public_read_access ? 1 : 0

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "bucket_listers" {
  provider = google
  count    = length(var.bucket_listers)

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = var.bucket_listers[count.index]
}

resource "google_storage_bucket_iam_member" "bucket_readers" {
  provider = google
  count    = length(var.bucket_readers)

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = var.bucket_readers[count.index]
}

resource "google_storage_bucket_iam_member" "bucket_writers" {
  provider = google
  count    = length(var.bucket_writers)

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectUser"
  member = var.bucket_writers[count.index]
}


