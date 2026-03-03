variable "project_id" {
  type        = string
  description = "GCP project ID for this environment"
}

variable "region" {
  type        = string
  description = "Default GCP region for this environment"
  default     = "us-central1"
}


