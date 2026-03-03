terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    # Adjust to your real remote backend bucket and prefix
    bucket = "CHANGE_ME_TF_STATE_BUCKET"
    prefix = "CHANGE_ME_ENV_DEV_PREFIX"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  environment = "dev"

  default_tags = {
    environment = local.environment
    managed_by  = "terraform"
  }
}


