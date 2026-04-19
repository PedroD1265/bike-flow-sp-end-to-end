terraform {
  required_version = ">= 1.6.0"

  backend "gcs" {
    bucket = "bikeflow-sp-dezoomcamp-tfstate"
    prefix = "bootstrap/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}