terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend configuration - descomentar y configurar según necesidad
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "analytical/terraform/state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

