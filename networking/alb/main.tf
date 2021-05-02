resource "aws_lb" "initial_alb" {
  name_prefix = var.alb_name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.initial_alb.arn
  port = local.http_port
  protocol = local.http_protocol

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Unlucky mate"
      status_code = local.not_found
    }
  }
}

resource "aws_security_group" "alb_sg" {
  name = var.alb_name
}

resource "aws_security_group_rule" "allow_http_inbound-alb_sg" {
  type = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# TO DO: why have I got ssh inbound to the alb?
resource "aws_security_group_rule" "allow_ssh_inbound-alb_sg" {
  type = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port = local.ssh_port
  to_port = local.ssh_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound-alb_sg" {
  type = "egress"
  security_group_id = aws_security_group.alb_sg.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}
