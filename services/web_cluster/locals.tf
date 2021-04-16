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
    Environment = "Staging"
    IAC = "terraform"
  }
}
