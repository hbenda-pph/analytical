# Analytical - BigQuery Analytics Queries

Proyecto para gestionar queries de análisis del dataset `pph-central.analytical` usando GitHub y Terraform.

## Estructura del Proyecto

```
Analytical/
├── .github/
│   └── workflows/          # GitHub Actions para CI/CD
│       ├── terraform.yml   # Pipeline de Terraform
│       └── sync.yml        # Pipeline de sincronización
├── bigquery/               # Queries SQL del dataset analytical (workspace de BigQuery Studio)
├── terraform/              # Infraestructura como código (Terraform)
│   ├── main.tf            # Configuración principal
│   ├── variables.tf       # Variables
│   ├── outputs.tf         # Outputs
│   ├── versions.tf        # Versiones de providers
│   ├── terraform.tfvars.example  # Ejemplo de configuración
│   └── README.md          # Documentación de Terraform
├── .gitignore             # Archivos ignorados por Git
└── README.md              # Este archivo
```

## Dataset

- **Proyecto**: `pph-central`
- **Dataset**: `analytical`

## Objetivos

1. **Sincronización GitHub ↔ BigQuery**: 
   - Sincronización bidireccional automática mediante **BigQuery Studio Repositories**
   - Los queries en `bigquery/` se sincronizan automáticamente con BigQuery
   - Control de versiones mediante Git

2. **Implementación con Terraform**: 
   - Los archivos SQL en `bigquery/` se implementan en GCloud mediante Terraform
   - Terraform lee los archivos SQL y crea recursos de BigQuery (views, scheduled queries)
   - Ejecutar `terraform apply` para desplegar los queries

3. **CI/CD**: Automatizar validaciones y despliegues mediante GitHub Actions

## Configuración Inicial

### Prerrequisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (opcional, para autenticación local)
- Cuenta de GCP con permisos apropiados
- Repositorio de GitHub configurado
- BigQuery Studio Repositories configurado (para sincronización)

### Setup Local

1. **Clonar el repositorio:**
   ```bash
   git clone <repository-url>
   cd Analytical
   ```

2. **Configurar Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus valores
   ```

3. **Autenticar con GCP:**
   ```bash
   gcloud auth application-default login
   ```

4. **Inicializar Terraform:**
   ```bash
   terraform init
   terraform validate
   ```

### Configuración de GitHub Actions

Para que los workflows funcionen, necesitas configurar los siguientes secrets en GitHub:

1. Ir a **Settings > Secrets and variables > Actions**
2. Agregar los siguientes secrets:
   - `GCP_PROJECT_ID`: ID del proyecto GCP
   - `GCP_SA_KEY`: JSON de la service account key (para autenticación)

## Uso

### Terraform

Ver documentación detallada en [terraform/README.md](terraform/README.md)

### Sincronización GitHub ↔ BigQuery

La sincronización se realiza mediante **BigQuery Studio Repositories** (integración nativa de GCP):

1. **Autenticar con GitHub (PASO CRÍTICO):**
   - En BigQuery Studio, ve a **Repositories**
   - Haz clic en **Connect repository** o **Authenticate with GitHub**
   - Se abrirá una ventana de autenticación OAuth de GitHub
   - **Autoriza a Google Cloud Platform** para acceder a tu repositorio
   - Asegúrate de otorgar permisos para:
     - Acceso al repositorio
     - Lectura y escritura de contenido
     - Acceso a metadata del repositorio
   - Completa el proceso de autenticación

2. **Configurar BigQuery Studio Repository:**
   - En BigQuery Studio, conectar el repositorio de GitHub (después de autenticar)
   - Configurar el workspace como `bigquery` (directorio donde BigQuery sincroniza)
   - Configurar el mapeo entre el repositorio y el dataset `analytical`
   - Los cambios se sincronizan automáticamente en ambas direcciones

2. **Flujo de trabajo:**
   - Editar queries en BigQuery Studio → Se sincronizan a GitHub en `bigquery/`
   - Editar archivos SQL en GitHub en `bigquery/` → Se sincronizan a BigQuery Studio
   - Los archivos en `bigquery/` son la fuente de verdad
   - Sincronización automática bidireccional
   - Control de versiones mediante Git

3. **Implementación con Terraform:**
   - Los archivos SQL en `bigquery/` son leídos directamente por Terraform
   - Se implementan como recursos de BigQuery (views, scheduled queries) al ejecutar `terraform apply`
   - No se requieren scripts adicionales

## Contribución

1. Crear una rama desde `develop`
2. Realizar cambios
3. Crear Pull Request hacia `develop` o `main`
4. Los workflows de GitHub Actions validarán automáticamente los cambios

## Solución de Problemas

### Error: "Repository is not authenticated"

Si obtienes este error al sincronizar desde BigQuery a GitHub:

1. **Re-autenticar con GitHub:**
   - Ve a BigQuery Studio → **Repositories**
   - Busca tu repositorio en la lista
   - Haz clic en **Re-authenticate** o **Disconnect** y vuelve a conectar
   - Completa el flujo OAuth de GitHub nuevamente

2. **Verificar permisos en GitHub:**
   - Ve a GitHub → **Settings** → **Applications** → **Authorized OAuth Apps**
   - Busca "Google Cloud Platform" o "BigQuery"
   - Verifica que tenga permisos de lectura/escritura en tu repositorio
   - Si es necesario, revoca y vuelve a autorizar

3. **Verificar configuración del repositorio:**
   - Asegúrate de que el repositorio existe y es accesible
   - Verifica que el workspace `bigquery` esté configurado correctamente
   - Confirma que la rama `main` existe en el repositorio

4. **Alternativa - Usar Personal Access Token:**
   - Si OAuth no funciona, puedes usar un Personal Access Token de GitHub
   - Crea un token en GitHub con permisos `repo`
   - Úsalo durante la configuración del repositorio en BigQuery

## Notas

- **Nunca commitees** archivos `terraform.tfvars` con valores reales
- Mantén las credenciales en GitHub Secrets
- Revisa los planes de Terraform antes de aplicar cambios en producción
- La autenticación OAuth puede expirar; re-autentica si es necesario

