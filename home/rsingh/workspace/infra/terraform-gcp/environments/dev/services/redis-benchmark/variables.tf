variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zone" {
  type        = string
  description = "GCP zone"
}

variable "environment" {
  type        = string
  description = "Environment label (e.g., dev, prod)"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork name"
}

variable "instance_name" {
  type        = string
  description = "Name of the VM instance"
}

variable "machine_type" {
  type        = string
  description = "Machine type"
}

variable "tags" {
  type        = list(string)
  description = "Additional network tags"
  default     = []
}

variable "metadata" {
  type        = map(string)
  description = "Instance metadata"
  default     = {}
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name          = string
    description   = optional(string)
    direction     = optional(string)
    priority      = optional(number)
    source_ranges = optional(list(string))
    target_tags   = optional(list(string))
    allowed       = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
    denied = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
}

variable "additional_disks" {
  type = list(object({
    name        = string
    size_gb     = number
    type        = string
    device_name = string
    auto_delete = bool
  }))
  default = []
}


