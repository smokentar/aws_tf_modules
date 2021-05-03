# Optional data sources based on input variables
# Created if specified vars default to null so as to populate with real data
# Excluded if specified vars have been injected manually for testing purposes

data "aws_ssm_parameter" "initial-db-pw" {
  count = var.db_username == null ? 1 : 0

  name = "initial-db-password"
}

data "aws_ssm_parameter" "initial-db-uname" {
  count = var.db_password == null ? 1 : 0

  name = "initial-db-username"
}
