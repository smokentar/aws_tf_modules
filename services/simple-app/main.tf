module "asg" {
  source = "../../clustering/asg-rolling-deploy"

  cluster_name  = "simple-app-${var.cluster_name}"
  live_ami      = var.live_ami
  user_data     = data.template_file.user_data.rendered
  instance_type = var.instance_type

  min_size_asg      = var.min_size_asg
  max_size_asg      = var.max_size_asg
  scheduled_actions = var.scheduled_actions

  subnet_ids        = local.subnet_ids
  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    user_data_server_port = local.http_port_non_privilege
    db_address            = local.mysql_config.endpoint #data.terraform_remote_state.db.outputs.mysql_export.endpoint
    db_port               = local.mysql_config.port     #data.terraform_remote_state.db.outputs.mysql_export.port
  }
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = local.alb_name
  subnet_ids = local.subnet_ids
}

resource "aws_lb_listener_rule" "http_forward_tg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "simple-app-${var.cluster_name}"
  port     = local.http_port_non_privilege
  protocol = local.http_protocol
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = local.http_protocol
    matcher             = local.success
    interval            = "5"
    timeout             = "3"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }
}
