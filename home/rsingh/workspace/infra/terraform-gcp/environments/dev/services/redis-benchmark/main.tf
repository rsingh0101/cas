terraform {
  backend "gcs" {
    bucket = "CHANGE_ME_TF_STATE_BUCKET"
    prefix = "CHANGE_ME_ENV_DEV_REDIS_BENCHMARK_PREFIX"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source = "../../../../modules/network"

  project_id    = var.project_id
  region        = var.region
  vpc_name      = var.vpc_name
  subnet_cidr   = var.subnet_cidr
  subnetwork    = var.subnetwork
  firewall_rules = var.firewall_rules
}

module "disks" {
  source = "../../../../modules/disks"

  project_id       = var.project_id
  zone             = var.zone
  additional_disks = var.additional_disks
}

module "compute" {
  source = "../../../../modules/compute"

  project_id              = var.project_id
  region                  = var.region
  zone                    = var.zone
  instance_name           = var.instance_name
  machine_type            = var.machine_type
  network                 = module.network.vpc_name
  subnetwork              = module.network.subnet_name
  tags                    = concat(local.default_tags_list, var.tags)
  metadata                = var.metadata
  additional_disks        = var.additional_disks
  additional_disk_sources = module.disks.disk_ids
}

locals {
  default_tags_list = [
    "env-${var.environment}",
    "service-redis-benchmark",
  ]
}


