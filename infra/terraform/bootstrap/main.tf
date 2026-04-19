resource "google_storage_bucket" "tfstate" {
  name                        = var.tfstate_bucket_name
  location                    = upper(var.location)
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  labels = {
    project = "bikeflow-sp"
    purpose = "terraform-state"
  }
}

resource "google_storage_bucket" "raw" {
  name                        = var.raw_bucket_name
  location                    = upper(var.location)
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = {
    project = "bikeflow-sp"
    purpose = "raw-lake"
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id                 = var.bq_dataset_raw
  location                   = var.location
  delete_contents_on_destroy = false

  labels = {
    project = "bikeflow-sp"
    layer   = "raw"
  }
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id                 = var.bq_dataset_analytics
  location                   = var.location
  delete_contents_on_destroy = false

  labels = {
    project = "bikeflow-sp"
    layer   = "analytics"
  }
}

output "tfstate_bucket_name" {
  value = google_storage_bucket.tfstate.name
}

output "raw_bucket_name" {
  value = google_storage_bucket.raw.name
}

output "bq_dataset_raw" {
  value = google_bigquery_dataset.raw.dataset_id
}

output "bq_dataset_analytics" {
  value = google_bigquery_dataset.analytics.dataset_id
}