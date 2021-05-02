# Optional data sources based on input variables
# Created if specified vars default to null so as to populate with real data
# Excluded if specified vars have been injected manually for testing purposes

data "aws_vpc" "default" {
  count = var.vpc_id == null ? 1 : 0

  default = true
}

data "aws_subnet_ids" "default" {
  count = var.subnet_ids == null ? 1 : 0

  vpc_id = local.vpc_id
}

data "terraform _remote_state" "db" {
  count = var.mysql_config == null ? 1 : 0

  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}
