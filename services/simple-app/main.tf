provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket #"terraform-state-20210408203821569800000001"
    key = var.db_remote_state_key #"staging/services/data_stores/mysql/terraform.tfstate"
    region = "us-east-1"
  }
}

module "asg" {
  source = "../../clustering/asg-rolling-deploy"

  cluster_name = "simple-app-${var.cluster_name}"
  ami = var.live_ami
  user_data = data.template_file.user_data.rendered
  instance_type = var.instance_type

  min_size = var.min_size_asg
  max_size = var.max_size_asg
  enable_autoscaling = var.scheduled_actions

  subnet_ids = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh") #file("../../../Modules/services/web_cluster/user-data.sh")
  vars = {
    user_data_server_port = local.http_port_non_privilege
    db_address = data.terraform_remote_state.db.outputs.mysql_export.endpoint
    db_port = data.terraform_remote_state.db.outputs.mysql_export.port
  }
}

module "alb" {
  source = "../../networking/alb"

  alb_name = "simple-app-${var.cluster_name}"
  subnet_ids = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener_rule" "http_forward_tg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name = "simple-app-${var.cluster_name}"
  port = local.http_port_non_privilege
  protocol = local.http_protocol
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = local.http_protocol
    matcher = local.success
    interval = "5"
    timeout = "3"
    healthy_threshold = "3"
    unhealthy_threshold = "3"
  }
}

#Commented out to test
/*
terraform {
  # Partial config; pulls data from backend.hcl
  backend "s3" {
    key = "staging/services/web-cluster/terraform.tfstate"
  }
}
*/
