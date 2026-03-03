variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region to deploy GKE cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the node pool"
  default     = 1
}

variable "machine_type" {
  type        = string
  description = "GCE machine type for cluster nodes"
  default     = "e2-micro"
}

variable "environment" {
  type        = string
  description = "Environment label (e.g., dev, prod)"
}


