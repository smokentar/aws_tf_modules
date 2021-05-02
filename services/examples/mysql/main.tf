provider "aws" {
  region = "us-east-1"
}

module "mysql" {
  source = "../../data_stores/mysql"

  db_username = var.db_username
  db_password = var.db_password

  db_instance_environment = "testing"

  custom_tags = {
    Environment = "Automated testing"
  }
}

terraform {
  # Partial config; pulls data from backend.hcl
  backend "s3" {
  }

  # Allow any 3.x version of the AWS provider
  required_providers {
    aws = "~> 3.0"
  }

  # Allow any 0.14.x version of Terraform
  required_version = ">= 0.14, < 0.15"
}

# Ensure that outputs from the module are exported to the tfstate file
# Post v12 outputs from child modules must be exported in the root module
output "mysql_export" {
  value = module.mysql
}
