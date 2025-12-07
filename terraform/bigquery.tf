# BigQuery Dataset - Usar dataset existente
# Si necesitas crear el dataset, descomenta el resource y comenta el data source
data "google_bigquery_dataset" "analytical" {
  dataset_id = var.dataset_id
  project    = var.project_id
}

# Si el dataset no existe y necesitas crearlo, descomenta esto:
# resource "google_bigquery_dataset" "analytical" {
#   dataset_id    = var.dataset_id
#   friendly_name = "Analytical Dataset"
#   description   = "Dataset for analytical queries managed via Terraform"
#   location      = var.region
#   project       = var.project_id
#
#   labels = {
#     environment = var.environment
#     managed_by  = "terraform"
#   }
# }

# BigQuery Views - Se crean dinámicamente desde archivos SQL en bigquery/
# Soporta archivos .sql y .bqsql
locals {
  sql_files = concat(
    tolist(fileset("${path.module}/../bigquery", "**/*.sql")),
    tolist(fileset("${path.module}/../bigquery", "**/*.bqsql"))
  )
  
  # Función helper para extraer solo el SELECT del archivo
  # Si tiene CREATE OR REPLACE VIEW, extrae solo la parte después de AS
  extract_query_content = {
    for file in local.sql_files :
    file => try(
      # Buscar "AS" (case insensitive) y capturar TODO lo que sigue
      # (?s) hace que . capture también saltos de línea
      regex("(?is)AS\\s+(.+)", file("${path.module}/../bigquery/${file}"))[0],
      # Si no tiene CREATE OR REPLACE VIEW, usar el contenido completo
      file("${path.module}/../bigquery/${file}")
    )
  }
}

resource "google_bigquery_table" "views" {
  for_each = {
    for file in local.sql_files :
    trimsuffix(basename(file), regex("\\.[^.]+$", basename(file))) => file
  }

  dataset_id = data.google_bigquery_dataset.analytical.dataset_id
  table_id   = each.key
  project    = var.project_id

  view {
    query          = local.extract_query_content[each.value]
    use_legacy_sql = false
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    source_file = replace(each.value, ".", "_")
  }

  depends_on = [data.google_bigquery_dataset.analytical]
}

