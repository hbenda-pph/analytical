# BigQuery Dataset
resource "google_bigquery_dataset" "analytical" {
  dataset_id    = var.dataset_id
  friendly_name = "Analytical Dataset"
  description   = "Dataset for analytical queries managed via Terraform"
  location      = var.region
  project       = var.project_id

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# BigQuery Views - Se crean dinámicamente desde archivos SQL en source/
resource "google_bigquery_table" "views" {
  for_each = {
    for file in fileset("${path.module}/../source", "**/*.sql") :
    trimsuffix(basename(file), ".sql") => file
  }

  dataset_id = google_bigquery_dataset.analytical.dataset_id
  table_id   = each.key
  project    = var.project_id

  view {
    query          = file("${path.module}/../source/${each.value}")
    use_legacy_sql = false
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    source_file = each.value
  }

  depends_on = [google_bigquery_dataset.analytical]
}

