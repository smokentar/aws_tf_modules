output "alb_dns_name" {
  description = "The DNS of the initial ALB"
  value = aws_lb.initial_alb.dns_name
}

output "asg_name" {
  description = "The name of the ASG"
  value = aws_autoscaling_group.initial_asg.name
}

output "initial_sg_id" {
  description = "The ID of the security group attached to the initial web servers"
  value = aws_security_group.initial_sg.id
}

output "alb_sg_id" {
  description = "The ID of the security group attached to the ALB fronting the initial web servers"
  value = aws_security_group.alb_sg.id
}
