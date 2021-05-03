locals {

  # Standardised tags which are required
  standard_tags = {
    IAC = "terraform"
  }

  # Conditional variables - use either data sources (real data) or input variables (dependency injection)
  db_username = (
    var.db_username == null
    ? data.aws_ssm_parameter.initial-db-uname[0].value
    : var.db_username
  )

  db_password = (
    var.db_password == null
    ? data.aws_ssm_parameter.initial-db-pw[0].value
    : var.db_password
  )
}
