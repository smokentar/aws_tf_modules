# Backend configuration for main.tf
# Introduced to allow automated testing
# Pass in with -backend-config=backend.hcl

bucket = "examples-terraform-state"
key = "services/examples/mysql/terraform.tfstate"
region = "us-east-1"
encrypt = true
