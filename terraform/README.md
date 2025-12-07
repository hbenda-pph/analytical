# Terraform - Infraestructura como Código

Este directorio contiene la configuración de Terraform para gestionar recursos en Google Cloud Platform.

## Estructura

```
terraform/
├── main.tf              # Configuración principal y providers
├── variables.tf         # Variables de entrada
├── outputs.tf          # Valores de salida
├── versions.tf         # Versiones de providers
├── terraform.tfvars.example  # Ejemplo de variables (copiar a terraform.tfvars)
└── modules/            # Módulos reutilizables (opcional)
```

## Configuración Inicial

1. **Copiar archivo de variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Editar `terraform.tfvars`** con tus valores específicos

3. **Configurar autenticación GCP:**
   ```bash
   gcloud auth application-default login
   ```

4. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

5. **Validar configuración:**
   ```bash
   terraform validate
   ```

6. **Ver plan de cambios:**
   ```bash
   terraform plan
   ```

7. **Aplicar cambios:**
   ```bash
   terraform apply
   ```

## Backend de Estado

Para usar un backend remoto en GCS (recomendado para producción):

1. Crear bucket de estado en GCS
2. Descomentar y configurar el bloque `backend "gcs"` en `main.tf`
3. Ejecutar `terraform init` nuevamente

## Variables Requeridas

- `project_id`: ID del proyecto GCP
- `region`: Región de GCP (default: us-central1)
- `dataset_id`: ID del dataset de BigQuery (default: analytical)
- `environment`: Ambiente (dev, staging, prod)

## Implementación de Queries

Terraform lee automáticamente todos los archivos `.sql` del directorio `bigquery/` y los crea como views en BigQuery:

- Cada archivo `nombre.sql` en `bigquery/` se crea como una view llamada `nombre`
- Los archivos se leen dinámicamente, no es necesario modificar Terraform al agregar nuevos queries
- Ejecutar `terraform plan` para ver qué views se crearán
- Ejecutar `terraform apply` para implementar las views en BigQuery

### Ejemplo

Si tienes `bigquery/example_view.sql`, Terraform creará una view `example_view` en el dataset `analytical`.

## Scheduled Queries

Para queries programados, configurar la variable `scheduled_queries` en `terraform.tfvars`:

```hcl
scheduled_queries = {
  "daily_report" = {
    query_file         = "daily_report.sql"
    schedule           = "every day 09:00"
    description        = "Daily report generation"
    destination_table  = "daily_report_results"
    write_disposition  = "WRITE_TRUNCATE"
  }
}
```

