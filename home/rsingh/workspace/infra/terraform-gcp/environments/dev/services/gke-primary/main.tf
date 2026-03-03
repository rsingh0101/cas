terraform {
  backend "gcs" {
    bucket = "CHANGE_ME_TF_STATE_BUCKET"
    prefix = "CHANGE_ME_ENV_DEV_GKE_PRIMARY_PREFIX"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke" {
  source       = "../../../../modules/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
  node_count   = var.node_count
  machine_type = var.machine_type
  environment  = var.environment
}


