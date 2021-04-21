locals {

  # Ports
  http_port_non_privilege = 8080
  any_port = 0

  # Protocols
  any_protocol = "-1"
  tcp_protocol = "tcp"

  # CIDR ranges
  all_ips = ["0.0.0.0/0"]

  # Standardised tags which are required
  standard_tags = {
    Name = var.cluster_name
    IAC = "terraform"
  }
}
