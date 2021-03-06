resource "aws_launch_configuration" "initial" {
  name_prefix     = "${var.cluster_name}-lc-"
  image_id        = var.live_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.initial_sg.id]

  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "initial_asg" {
  # Ensure this ASG depends on the LC's name to enforce replacement
  name                 = "${var.cluster_name}-${aws_launch_configuration.initial.name}"
  launch_configuration = aws_launch_configuration.initial.name
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size_asg
  max_size = var.max_size_asg

  # Stand by for a number of instances to pass health checks before promoting the new ASG
  min_elb_capacity = var.min_size_asg

  # Create a new ASG, promote and delete old ASG
  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = local.standard_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.scheduled_actions ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.initial_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_after_business_hours" {
  count = var.scheduled_actions ? 1 : 0

  scheduled_action_name = "scale-in-after-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.initial_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name  = "${var.cluster_name}-high-cpu"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.initial_asg.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.cluster_name}-low-cpu-credit"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.initial_asg.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

resource "aws_security_group" "initial_sg" {
  name = "${var.cluster_name}-sg"
}

resource "aws_security_group_rule" "allow_http_inbound-initial_sg" {
  type              = "ingress"
  security_group_id = aws_security_group.initial_sg.id

  from_port   = local.http_port_non_privilege
  to_port     = local.http_port_non_privilege
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound-initial_sg" {
  type              = "egress"
  security_group_id = aws_security_group.initial_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
