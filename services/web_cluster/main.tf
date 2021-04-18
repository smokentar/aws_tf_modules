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

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh") #file("../../../Modules/services/web_cluster/user-data.sh")
  vars = {
    user_data_server_port = local.http_port_non_privilege
    db_address = data.terraform_remote_state.db.outputs.mysql_export.endpoint
    db_port = data.terraform_remote_state.db.outputs.mysql_export.port
  }
}

resource "aws_launch_configuration" "initial" {
  name_prefix = "${var.cluster_name}-lc-"
  image_id = var.live_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.initial_sg.id]

  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "initial_asg" {
  name = "${var.cluster_name}-asg"
  launch_configuration = aws_launch_configuration.initial.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  health_check_type = "ELB"

  min_size = var.min_size_asg
  max_size = var.max_size_asg

  dynamic "tag" {
    for_each = local.standard_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.scheduled_actions ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.initial_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_after_business_hours" {
  count = var.scheduled_actions ? 1 : 0

  scheduled_action_name = "scale-in-after-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.initial_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "${var.cluster_name}-high-cpu"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.initial_asg.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name ="${var.cluster_name}-low-cpu-credit"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.initial_asg .name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}

resource "aws_security_group" "initial_sg" {
  name = "${var.cluster_name}-sg"
}

resource "aws_security_group_rule" "allow_http_inbound-initial_sg" {
  type = "ingress"
  security_group_id = aws_security_group.initial_sg.id

  from_port = local.http_port_non_privilege
  to_port = local.http_port_non_privilege
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound-initial_sg" {
  type = "egress"
  security_group_id = aws_security_group.initial_sg.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group" "alb_sg" {
  name = "${var.cluster_name}-alb-sg"
}

resource "aws_security_group_rule" "allow_http_inbound-alb_sg" {
  type = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

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

resource "aws_lb" "initial_alb" {
  name = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
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

resource "aws_lb_listener_rule" "http_forward_tg" {
  listener_arn = aws_lb_listener.http.arn
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
  name = "${var.cluster_name}-alb-tg"
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
