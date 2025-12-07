# Scheduled Queries - Para queries que necesitan ejecutarse periódicamente
# Configurar en terraform.tfvars usando la variable scheduled_queries

variable "scheduled_queries" {
  description = "Map of scheduled queries configuration"
  type = map(object({
    query_file     = string
    schedule       = string
    description  = string
    destination_table = optional(string)
    write_disposition = optional(string)
  }))
  default = {}
}

resource "google_bigquery_data_transfer_config" "scheduled_queries" {
  for_each = var.scheduled_queries

  display_name           = each.key
  location               = var.region
  data_source_id         = "scheduled_query"
  schedule               = each.value.schedule
  destination_dataset_id = data.google_bigquery_dataset.analytical.dataset_id
  project                = var.project_id

  params = {
    query                  = file("${path.module}/../bigquery/${each.value.query_file}")
    destination_table_name_template = each.value.destination_table != null ? each.value.destination_table : "${each.key}_results"
    write_disposition      = each.value.write_disposition != null ? each.value.write_disposition : "WRITE_TRUNCATE"
  }

  depends_on = [data.google_bigquery_dataset.analytical]
}

