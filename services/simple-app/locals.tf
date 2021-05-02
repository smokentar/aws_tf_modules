locals {

  # Ports
  http_port = 80
  ssh_port = 22
  http_port_non_privilege = 8080
  any_port = 0

  # Protocols
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "HTTP"

  # CIDR ranges
  all_ips = ["0.0.0.0/0"]

  # Response codes
  not_found = "404"
  success = "200"

  # Standardised tags which are required
  standard_tags = {
    Name = var.cluster_name
    IAC = "terraform"
  }

  # Conditional variables - use either data sources (real data) or input variables (dependency injection)
  mysql_config = (
    var.mysql_config == null
      ? data.terraform_remote_state.db[0].outputs.mysql_export
      : var.mysql_config
    )

  vpc_id = (
    var.vpc_id == null
      ? data.aws_vpc.default[0].id
      : var.vpc_id
    )

  subnet_ids = (
    var.subnet_ids == null
      ? data.aws_subnet_ids.default[0].ids
      : var.subnet_ids
    )

  alb_name = (
    var.alb_name == null
      ? "simple-app-${var.cluster_name}"
      : var.alb_name
    )
}
