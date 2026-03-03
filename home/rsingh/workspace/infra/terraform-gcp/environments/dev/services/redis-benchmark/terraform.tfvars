## Example redis-benchmark service values.
## Fill these with your own project/env-specific settings.

# project_id  = "your-gcp-project-id"
# region      = "your-gcp-region"
# zone        = "your-gcp-zone"
# environment = "dev"

# vpc_name    = "your-vpc-name"
# subnet_cidr = "10.0.0.0/16"
# subnetwork  = "your-subnet-name"

# instance_name = "benchmark"
# machine_type  = "e2-medium"

# tags = [
#   "benchmark",
# ]

# metadata = {
#   startup-script = <<-EOT
#     #!/bin/bash
#     # your startup script here
#   EOT
# }

# firewall_rules = [
#   {
#     name        = "allow-benchmark"
#     description = "Allow app endpoints"
#     direction   = "INGRESS"
#     priority    = 1000
#     source_ranges = ["0.0.0.0/0"]
#     target_tags   = ["benchmark"]
#     allowed = [
#       {
#         protocol = "tcp"
#         ports    = ["22", "80", "443", "3000", "9090"]
#       }
#     ]
#   }
# ]

# additional_disks = []



